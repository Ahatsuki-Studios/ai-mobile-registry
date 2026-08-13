@echo off
REM Offline M5.2a prepare: validate + generate unsigned v3 candidate (gitignored local output).
REM Does NOT production-sign. Does NOT write v1/catalog-schema-v3/current.json.
REM Safe for Windows paths with spaces (no Gradle --args path list).
setlocal EnableExtensions
set "SCRIPT_DIR=%~dp0"
set "REGISTRY_ROOT=%SCRIPT_DIR%.."
for %%I in ("%REGISTRY_ROOT%") do set "REGISTRY_ROOT=%%~fI"
set "APP_ANDROID=%REGISTRY_ROOT%\..\ai-mobile\android-app"
for %%I in ("%APP_ANDROID%") do set "APP_ANDROID=%%~fI"
if not exist "%APP_ANDROID%\gradlew.bat" (
  echo ERROR: ai-mobile android-app not found at %APP_ANDROID%
  exit /b 2
)
set "ARGS_FILE=%TEMP%\aimobile-registry-prepare-args.txt"
(
  echo prepare
) > "%ARGS_FILE%"
pushd "%APP_ANDROID%"
call gradlew.bat :tools:registry-prepare:run -PtoolArgsFile="%ARGS_FILE%"
set ERR=%ERRORLEVEL%
popd
exit /b %ERR%
