@echo off
REM Safe NON-PRODUCTION console signing test with ephemeral encrypted PKCS#8.
REM Does NOT use aimobile-registry-2026-01 production key.
REM Passphrase: enter ONLY at the hidden interactive prompt (see printed test passphrase).
setlocal EnableExtensions
call "%~dp0_resolve-sibling-paths.bat"
call "%~dp0_ensure-java21.bat"
if errorlevel 1 exit /b %ERRORLEVEL%

set "PROBE_DIR=%TEMP%\aimobile-console-probe"
set "PRIVATE_KEY=%PROBE_DIR%\test-encrypted-private.pem"
set "PUBLIC_KEY=%PROBE_DIR%\test-public.pem"
set "PAYLOAD=%PROBE_DIR%\test-payload.json"
set "OUT=%PROBE_DIR%\test-envelope.json"
set "ARGS_FILE=%PROBE_DIR%\sign-args.txt"
set "TEST_PASSPHRASE=m52b-console-test"

echo Registry root:   %REGISTRY_ROOT%
echo AI Mobile root:  %AI_MOBILE_ROOT%
echo Android app:     %APP_ANDROID%
echo Signer launcher: %SIGNER_LAUNCHER%

if not exist "%APP_ANDROID%\gradlew.bat" (
  echo ERROR: android-app not found: %APP_ANDROID%
  exit /b 2
)

set "OPENSSL="
if exist "C:\Program Files\Git\usr\bin\openssl.exe" set "OPENSSL=C:\Program Files\Git\usr\bin\openssl.exe"
if not defined OPENSSL if exist "C:\Program Files\Git\mingw64\bin\openssl.exe" set "OPENSSL=C:\Program Files\Git\mingw64\bin\openssl.exe"
if not defined OPENSSL if exist "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" set "OPENSSL=C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
if not defined OPENSSL (
  echo ERROR: OpenSSL not found. Install Git for Windows OpenSSL to generate the throwaway test key.
  exit /b 2
)

if not exist "%PROBE_DIR%" mkdir "%PROBE_DIR%"
if exist "%PRIVATE_KEY%" del /f /q "%PRIVATE_KEY%" >nul 2>&1
if exist "%PUBLIC_KEY%" del /f /q "%PUBLIC_KEY%" >nul 2>&1
if exist "%OUT%" del /f /q "%OUT%" >nul 2>&1

echo.
echo Generating FRESH throwaway encrypted PKCS#8 test key ^(NOT production^)...
echo Format: OpenSSL genpkey EC P-256 + PBES2/PBKDF2^(hmacWithSHA256^) + AES-256-CBC
echo         same contract as production: openssl genpkey ... -aes-256-cbc
"%OPENSSL%" genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -aes-256-cbc -pass pass:%TEST_PASSPHRASE% -out "%PRIVATE_KEY%"
if errorlevel 1 (
  echo ERROR: throwaway private key generation failed.
  exit /b 2
)
"%OPENSSL%" pkey -in "%PRIVATE_KEY%" -passin pass:%TEST_PASSPHRASE% -pubout -out "%PUBLIC_KEY%"
if errorlevel 1 (
  echo ERROR: throwaway public key export failed.
  exit /b 2
)
> "%PAYLOAD%" echo {"schemaVersion":2,"models":[]}

findstr /C:"BEGIN ENCRYPTED PRIVATE KEY" "%PRIVATE_KEY%" >nul
if errorlevel 1 (
  echo ERROR: expected BEGIN ENCRYPTED PRIVATE KEY header.
  exit /b 2
)

echo Building installDist...
pushd "%APP_ANDROID%"
call gradlew.bat :tools:registry-sign:installDist
set ERR=%ERRORLEVEL%
popd
if not "%ERR%"=="0" exit /b %ERR%
if not exist "%SIGNER_LAUNCHER%" (
  echo ERROR: launcher missing: %SIGNER_LAUNCHER%
  exit /b 2
)

(
  echo --payload
  echo %PAYLOAD%
  echo --registry-version
  echo 1
  echo --key-id
  echo test-console-key
  echo --private-key
  echo %PRIVATE_KEY%
  echo --public-key
  echo %PUBLIC_KEY%
  echo --out
  echo %OUT%
  echo --generated-at
  echo 1786616929326
) > "%ARGS_FILE%"

echo.
echo ============================================================
echo TEST ONLY — throwaway encrypted PKCS#8 console signing
echo ============================================================
echo Type this throwaway passphrase at the HIDDEN prompt:
echo   %TEST_PASSPHRASE%
echo Enter it twice. Exact match, no extra spaces.
echo Do NOT paste the production passphrase.
echo ============================================================
echo.
call "%SIGNER_LAUNCHER%" --args-file "%ARGS_FILE%"
set ERR=%ERRORLEVEL%
if not "%ERR%"=="0" (
  echo ERROR: test signer exited with code %ERR%. No envelope accepted.
  exit /b %ERR%
)
if not exist "%OUT%" (
  echo ERROR: test signer exit 0 but output missing: %OUT%
  exit /b 1
)
for %%F in ("%OUT%") do set "OUT_SIZE=%%~zF"
if "%OUT_SIZE%"=="" set "OUT_SIZE=0"
if %OUT_SIZE% LEQ 0 (
  echo ERROR: test signer exit 0 but output empty: %OUT%
  exit /b 1
)
echo.
echo Test envelope: %OUT% ^(size=%OUT_SIZE%^)
echo Expected: self-verification=PASS above.
exit /b 0
