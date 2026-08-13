@echo off
REM Shared sibling-repo path resolution for ai-mobile-registry\tools\*.bat
REM Layout:
REM   WORKSPACE_ROOT\
REM     ai-mobile\android-app\
REM     ai-mobile-registry\tools\  (this script's parent)
REM Sets: SCRIPT_DIR, REGISTRY_ROOT, WORKSPACE_ROOT, AI_MOBILE_ROOT, APP_ANDROID, SIGNER_LAUNCHER
REM Does not change directory. Safe with spaces when callers quote variables.

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%.") do set "SCRIPT_DIR=%%~fI\"

set "REGISTRY_ROOT=%SCRIPT_DIR%.."
for %%I in ("%REGISTRY_ROOT%") do set "REGISTRY_ROOT=%%~fI"

set "WORKSPACE_ROOT=%REGISTRY_ROOT%\.."
for %%I in ("%WORKSPACE_ROOT%") do set "WORKSPACE_ROOT=%%~fI"

set "AI_MOBILE_ROOT=%WORKSPACE_ROOT%\ai-mobile"
for %%I in ("%AI_MOBILE_ROOT%") do set "AI_MOBILE_ROOT=%%~fI"

set "APP_ANDROID=%AI_MOBILE_ROOT%\android-app"
for %%I in ("%APP_ANDROID%") do set "APP_ANDROID=%%~fI"

set "SIGNER_LAUNCHER=%AI_MOBILE_ROOT%\tools\registry-sign\build\install\registry-sign\bin\registry-sign.bat"
for %%I in ("%SIGNER_LAUNCHER%") do set "SIGNER_LAUNCHER=%%~fI"
