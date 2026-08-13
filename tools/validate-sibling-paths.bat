@echo off
REM Non-interactive path resolution self-check (no signing, no secrets).
setlocal EnableExtensions
call "%~dp0_resolve-sibling-paths.bat"
echo REGISTRY_ROOT=%REGISTRY_ROOT%
echo WORKSPACE_ROOT=%WORKSPACE_ROOT%
echo AI_MOBILE_ROOT=%AI_MOBILE_ROOT%
echo APP_ANDROID=%APP_ANDROID%
echo SIGNER_LAUNCHER=%SIGNER_LAUNCHER%
set ERR=0
if /I not "%REGISTRY_ROOT%"=="D:\Cursor AI - Projecten\FUTURE APP\ai-mobile-registry" (
  echo FAIL: unexpected REGISTRY_ROOT
  set ERR=1
)
if /I not "%WORKSPACE_ROOT%"=="D:\Cursor AI - Projecten\FUTURE APP" (
  echo FAIL: unexpected WORKSPACE_ROOT
  set ERR=1
)
if /I not "%AI_MOBILE_ROOT%"=="D:\Cursor AI - Projecten\FUTURE APP\ai-mobile" (
  echo FAIL: unexpected AI_MOBILE_ROOT
  set ERR=1
)
if /I not "%APP_ANDROID%"=="D:\Cursor AI - Projecten\FUTURE APP\ai-mobile\android-app" (
  echo FAIL: unexpected APP_ANDROID
  set ERR=1
)
if not exist "%APP_ANDROID%\gradlew.bat" (
  echo FAIL: gradlew.bat missing at APP_ANDROID
  set ERR=1
) else (
  echo APP_EXISTS=YES
)
if exist "%SIGNER_LAUNCHER%" (
  echo LAUNCHER_EXISTS=YES
) else (
  echo LAUNCHER_EXISTS=NO ^(run installDist first^)
)
if "%ERR%"=="0" (
  echo path-resolution=PASS
) else (
  echo path-resolution=FAIL
)
exit /b %ERR%
