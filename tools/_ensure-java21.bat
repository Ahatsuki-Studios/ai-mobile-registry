@echo off
REM Wrapper-local JDK 21+ selection for standalone registry-sign launcher.
REM Call from an operator wrapper that already ran setlocal.
REM Does NOT use setx / registry / permanent user or system env.
REM Sets process-local JAVA_HOME and prepends %%JAVA_HOME%%\bin to PATH.
REM
REM Selection order:
REM   1) Existing JAVA_HOME if java.exe major ^>= 21
REM   2) Newest Eclipse Temurin/Adoptium JDK 21+ under Program Files
REM   3) Fail clearly — never fall back to whatever java.exe is first on PATH

set "_AIM_JAVA_CANDIDATE="
set "_AIM_JAVA_MAJOR="

if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" goto AIM_TRY_EXISTING
goto AIM_TRY_ADOPTIUM

:AIM_TRY_EXISTING
call :AIM_JAVA_MAJOR "%JAVA_HOME%"
if not defined _AIM_JAVA_MAJOR goto AIM_TRY_ADOPTIUM
if %_AIM_JAVA_MAJOR% LSS 21 (
  echo NOTE: Ignoring incompatible JAVA_HOME ^(major %_AIM_JAVA_MAJOR%^): %JAVA_HOME%
  goto AIM_TRY_ADOPTIUM
)
set "_AIM_JAVA_CANDIDATE=%JAVA_HOME%"
goto AIM_JAVA_APPLY

:AIM_TRY_ADOPTIUM
set "_AIM_JAVA_CANDIDATE="
if exist "C:\Program Files\Eclipse Adoptium\jdk-21.0.6.7-hotspot\bin\java.exe" (
  set "_AIM_JAVA_CANDIDATE=C:\Program Files\Eclipse Adoptium\jdk-21.0.6.7-hotspot"
  goto AIM_JAVA_APPLY
)
for /d %%D in ("C:\Program Files\Eclipse Adoptium\jdk-21*") do (
  if exist "%%~fD\bin\java.exe" set "_AIM_JAVA_CANDIDATE=%%~fD"
)
if defined _AIM_JAVA_CANDIDATE goto AIM_JAVA_APPLY
goto AIM_JAVA_FAIL

:AIM_JAVA_FAIL
echo ERROR: No JDK 21+ found for registry-sign.
echo   registry-sign is compiled with jvmToolchain^(21^) ^(class file 65^).
echo   The standalone launcher must not use Java 17 ^(class file 61^).
echo   Set JAVA_HOME to a JDK 21+ for this cmd session, or install Eclipse Temurin 21+.
if defined JAVA_HOME (
  echo   Rejected JAVA_HOME: %JAVA_HOME%
  if exist "%JAVA_HOME%\bin\java.exe" "%JAVA_HOME%\bin\java.exe" -version 2>&1
)
set "_AIM_JAVA_CANDIDATE="
set "_AIM_JAVA_MAJOR="
exit /b 2

:AIM_JAVA_APPLY
for %%I in ("%_AIM_JAVA_CANDIDATE%") do set "JAVA_HOME=%%~fI"
set "PATH=%JAVA_HOME%\bin;%PATH%"
call :AIM_JAVA_MAJOR "%JAVA_HOME%"
if not defined _AIM_JAVA_MAJOR (
  echo ERROR: Could not read Java major from: %JAVA_HOME%
  set "_AIM_JAVA_CANDIDATE="
  exit /b 2
)
if %_AIM_JAVA_MAJOR% LSS 21 (
  echo ERROR: Signer Java major must be ^>= 21. Got %_AIM_JAVA_MAJOR% at:
  echo   %JAVA_HOME%
  "%JAVA_HOME%\bin\java.exe" -version 2>&1
  set "_AIM_JAVA_CANDIDATE="
  set "_AIM_JAVA_MAJOR="
  exit /b 2
)
echo Signer JAVA_HOME: %JAVA_HOME%
echo Signer Java major: %_AIM_JAVA_MAJOR%
"%JAVA_HOME%\bin\java.exe" -version 2>&1
set "_AIM_JAVA_CANDIDATE="
set "_AIM_JAVA_MAJOR="
exit /b 0

:AIM_JAVA_MAJOR
set "_AIM_JAVA_MAJOR="
set "_AIM_JAVA_LINE="
for /f "delims=" %%L in ('"%~1\bin\java.exe" -version 2^>^&1') do (
  if not defined _AIM_JAVA_LINE set "_AIM_JAVA_LINE=%%L"
)
if not defined _AIM_JAVA_LINE exit /b 0
for /f "tokens=3" %%V in ("%_AIM_JAVA_LINE%") do set "_AIM_JAVA_VER=%%~V"
if not defined _AIM_JAVA_VER exit /b 0
for /f "tokens=1 delims=." %%M in ("%_AIM_JAVA_VER%") do set "_AIM_JAVA_MAJOR=%%M"
set "_AIM_JAVA_LINE="
set "_AIM_JAVA_VER="
exit /b 0
