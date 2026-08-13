@echo off
REM Probes System.console() via the standalone registry-sign launcher (outside Gradle).
REM Run from a real Windows cmd.exe. Exit 0 = PASS.
setlocal EnableExtensions
call "%~dp0_resolve-sibling-paths.bat"
call "%~dp0_ensure-java21.bat"
if errorlevel 1 exit /b %ERRORLEVEL%

echo Registry root:   %REGISTRY_ROOT%
echo Workspace root:  %WORKSPACE_ROOT%
echo AI Mobile root:  %AI_MOBILE_ROOT%
echo Android app:     %APP_ANDROID%
echo Signer launcher: %SIGNER_LAUNCHER%

if not exist "%APP_ANDROID%\gradlew.bat" (
  echo ERROR: android-app not found: %APP_ANDROID%
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

echo Probing console via direct launcher...
call "%SIGNER_LAUNCHER%" --probe-console
exit /b %ERRORLEVEL%
