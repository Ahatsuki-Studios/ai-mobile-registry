@echo off
REM M5.2b helper template: production-sign generated candidate via args file.
REM Does NOT embed passphrase. Private key path is EXTERNAL.
REM Safe for Windows paths containing spaces.
setlocal EnableExtensions
set "SCRIPT_DIR=%~dp0"
set "REGISTRY_ROOT=%SCRIPT_DIR%.."
for %%I in ("%REGISTRY_ROOT%") do set "REGISTRY_ROOT=%%~fI"
set "APP_ANDROID=%REGISTRY_ROOT%\..\ai-mobile\android-app"
for %%I in ("%APP_ANDROID%") do set "APP_ANDROID=%%~fI"

if "%~1"=="" (
  echo Usage: sign-v3-candidate.bat ^<external-private-key.pem^> ^<public-key.pem^> [generatedAtEpochMillis]
  echo.
  echo Payload default: generated-candidates\m5.2a-production-v3-catalog.json
  echo Out default:     %%TEMP%%\catalog-schema-v3-current.json
  echo.
  echo After PASS, operator copies signed envelope to v1\catalog-schema-v3\current.json
  exit /b 2
)

set "PRIVATE_KEY=%~1"
set "PUBLIC_KEY=%~2"
set "GENERATED_AT=%~3"
if "%GENERATED_AT%"=="" set "GENERATED_AT=0"

set "PAYLOAD=%REGISTRY_ROOT%\generated-candidates\m5.2a-production-v3-catalog.json"
set "OUT=%TEMP%\catalog-schema-v3-current.json"
set "ARGS_FILE=%TEMP%\aimobile-registry-sign-args.txt"

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

(
  echo --payload
  echo %PAYLOAD%
  echo --registry-version
  echo 1
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

echo Writing args file: %ARGS_FILE%
echo Payload: %PAYLOAD%
echo Out: %OUT%
echo.
echo M5.2b ONLY — interactive passphrase prompt may appear. Never pass passphrase via CLI/env.
pushd "%APP_ANDROID%"
call gradlew.bat :tools:registry-sign:run -PtoolArgsFile="%ARGS_FILE%"
set ERR=%ERRORLEVEL%
popd
if not "%ERR%"=="0" exit /b %ERR%
echo.
echo Signed envelope at: %OUT%
echo Next: copy to "%REGISTRY_ROOT%\v1\catalog-schema-v3\current.json" after review.
echo Leave v1\current.json unchanged.
exit /b 0
