@echo off
REM Wrapper script to run secret-scan.sh with proper environment on Windows
setlocal enabledelayedexpansion

REM Try to find betterleaks, or gitleaks in PATH
where /q gitleaks.exe
if %errorlevel% equ 0 (
    gitleaks git --redact=80 --no-banner --timeout 2 -v --max-target-megabytes=2 --pre-commit --staged
    exit /b %errorlevel%
)

where /q betterleaks.exe
if %errorlevel% equ 0 (
    betterleaks
    exit /b %errorlevel%
)

REM Try common installation locations
if exist "C:\ProgramData\chocolatey\bin\gitleaks.exe" (
    "C:\ProgramData\chocolatey\bin\gitleaks.exe" git --redact=80 --no-banner --timeout 2 -v --max-target-megabytes=2 --pre-commit --staged
    exit /b %errorlevel%
)

if exist "%USERPROFILE%\scoop\shims\gitleaks.exe" (
    "%USERPROFILE%\scoop\shims\gitleaks.exe" git --redact=80 --no-banner --timeout 2 -v --max-target-megabytes=2 --pre-commit --staged
    exit /b %errorlevel%
)

if exist "%LOCALAPPDATA%\Microsoft\WinGet\Links\gitleaks.exe" (
    "%LOCALAPPDATA%\Microsoft\WinGet\Links\gitleaks.exe" git --redact=80 --no-banner --timeout 2 -v --max-target-megabytes=2 --pre-commit --staged
    exit /b %errorlevel%
)

REM Fallback to bash script
bash "%~dp0secret-scan.sh"
exit /b %errorlevel%
