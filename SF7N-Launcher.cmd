@echo off
set "SF7NLocation=%~dp0\SF7N-Resources\SF7N-Loader.ps1"

if "%OS%" NEQ "Windows_NT" call :error "Unsupported OS" "Only Windows NT-based OSes are supported."
if not exist "%SF7NLocation%" call :error "SF7N Missing" "Update the path in variable SF7NLocation in %~dpf0"

echo Press [R] key if prompted below.
powershell.exe -File "%SF7NLocation%"
exit /b

:error
echo Error: %~1
echo(
echo %~2
echo Please press any key to exit
>nul pause
exit