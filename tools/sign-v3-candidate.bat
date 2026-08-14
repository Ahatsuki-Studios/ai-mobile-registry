@echo off
REM M5.2b production signing wrapper.
REM 1) Gradle builds/installs the standalone registry-sign distribution (no signing).
REM 2) The installDist Windows launcher is invoked DIRECTLY from this cmd.exe process
REM    so System.console() works for the encrypted PKCS#8 passphrase prompt.
REM Passphrase: interactive hidden console only. Never CLI/env/args-file/Git.
setlocal EnableExtensions
call "%~dp0_resolve-sibling-paths.bat"
call "%~dp0_ensure-java21.bat"
if errorlevel 1 exit /b %ERRORLEVEL%

if "%~1"=="" (
  echo Usage: sign-v3-candidate.bat ^<external-private-key.pem^> ^<public-key.pem^> [generatedAtEpochMillis] [registryVersion]
  echo.
  echo Payload default: generated-candidates\m5.2a-production-v3-catalog.json
  echo Out default:     %%TEMP%%\catalog-schema-v3-current.json
  echo registryVersion: required positive integer ^(4th arg^). No silent default.
  echo.
  echo Build uses Gradle installDist. Signing runs outside Gradle JavaExec.
  echo After PASS, operator copies signed envelope to v1\catalog-schema-v3\current.json
  exit /b 2
)

set "PRIVATE_KEY=%~1"
set "PUBLIC_KEY=%~2"
set "GENERATED_AT=%~3"
set "REGISTRY_VERSION=%~4"
if "%GENERATED_AT%"=="" set "GENERATED_AT=0"
if "%REGISTRY_VERSION%"=="" (
  echo ERROR: registryVersion ^(4th argument^) is required and must be a positive integer.
  echo Example: sign-v3-candidate.bat key.pem pub.pem 0 2
  exit /b 2
)

set "PAYLOAD=%REGISTRY_ROOT%\generated-candidates\m5.2a-production-v3-catalog.json"
set "OUT=%TEMP%\catalog-schema-v3-current.json"
set "ARGS_FILE=%TEMP%\aimobile-registry-sign-args.txt"

echo Registry root:   %REGISTRY_ROOT%
echo Workspace root:  %WORKSPACE_ROOT%
echo AI Mobile root:  %AI_MOBILE_ROOT%
echo Android app:     %APP_ANDROID%
echo Signer launcher: %SIGNER_LAUNCHER%
echo Payload:         %PAYLOAD%
echo Out:             %OUT%
echo registryVersion: %REGISTRY_VERSION%

if not exist "%PAYLOAD%" (
  echo ERROR: payload missing. Run prepare-v3-candidate.bat first: %PAYLOAD%
  exit /b 2
)
if not exist "%PRIVATE_KEY%" (
  echo ERROR: private key not found: %PRIVATE_KEY%
  exit /b 2
)
if not exist "%PUBLIC_KEY%" (
  echo ERROR: public key not found: %PUBLIC_KEY%
  exit /b 2
)
if not exist "%APP_ANDROID%\gradlew.bat" (
  echo ERROR: ai-mobile android-app not found at %APP_ANDROID%
  exit /b 2
)

echo Building standalone registry-sign distribution via Gradle installDist...
pushd "%APP_ANDROID%"
call gradlew.bat :tools:registry-sign:installDist
set ERR=%ERRORLEVEL%
popd
if not "%ERR%"=="0" (
  echo ERROR: installDist failed.
  exit /b %ERR%
)
if not exist "%SIGNER_LAUNCHER%" (
  echo ERROR: signer launcher missing after installDist: %SIGNER_LAUNCHER%
  exit /b 2
)

REM Re-assert JDK 21+ after Gradle ^(in case the daemon mutated PATH/JAVA_HOME^).
call "%~dp0_ensure-java21.bat"
if errorlevel 1 exit /b %ERRORLEVEL%

(
  echo --payload
  echo %PAYLOAD%
  echo --registry-version
  echo %REGISTRY_VERSION%
  echo --key-id
  echo aimobile-registry-2026-01
  echo --private-key
  echo %PRIVATE_KEY%
  echo --public-key
  echo %PUBLIC_KEY%
  echo --out
  echo %OUT%
  if not "%GENERATED_AT%"=="0" (
    echo --generated-at
    echo %GENERATED_AT%
  )
) > "%ARGS_FILE%"

echo.
echo Args file (non-secret only): %ARGS_FILE%
echo.
echo Invoking signer DIRECTLY outside Gradle JavaExec.
echo Interactive passphrase prompt should appear (hidden). Never pass passphrase via CLI/env.
call "%SIGNER_LAUNCHER%" --args-file "%ARGS_FILE%"
set ERR=%ERRORLEVEL%
if not "%ERR%"=="0" (
  echo ERROR: signer exited with code %ERR%. No signed envelope accepted.
  exit /b %ERR%
)
if not exist "%OUT%" (
  echo ERROR: signer exit 0 but output file missing: %OUT%
  exit /b 1
)
for %%F in ("%OUT%") do set "OUT_SIZE=%%~zF"
if "%OUT_SIZE%"=="" set "OUT_SIZE=0"
if %OUT_SIZE% LEQ 0 (
  echo ERROR: signer exit 0 but output file empty: %OUT%
  exit /b 1
)
echo.
echo Signed envelope at: %OUT% ^(size=%OUT_SIZE%^)
echo Next: verify envelope, then copy to "%REGISTRY_ROOT%\v1\catalog-schema-v3\current.json"
echo Leave v1\current.json unchanged.
exit /b 0
