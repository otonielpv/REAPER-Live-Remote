@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

REM ============================================================
REM REAPER Live Remote - Instalador Rápido
REM ============================================================

REM Detect language
for /f "tokens=2 delims==" %%i in ('wmic os get locale /value 2^>nul') do set LOCALE=%%i
if "%LOCALE%"=="080A" set LANG=es
if "%LOCALE%"=="0C0A" set LANG=es
if "%LOCALE%"=="0409" set LANG=en
if "%LOCALE%"=="1009" set LANG=en
if "%LANG%"=="es" (
    set TITLE=REAPER Live Remote - Instalador Automático
    set MSG_CONFIG=Este instalador configurará todo automáticamente.
    set MSG_PRESS=Presiona cualquier tecla para continuar...
    set MSG_RUNNING=Ejecutando instalador...
    set MSG_ERROR=Hubo un problema durante la instalación.
    set MSG_PRESS_EXIT=Presiona una tecla para salir
    set MSG_COMPLETE=Instalación completada.
    set MSG_PRESS_FINISH=Presiona una tecla para finalizar
) else (
    set TITLE=REAPER Live Remote - Automatic Installer
    set MSG_CONFIG=This installer will configure everything automatically.
    set MSG_PRESS=Press any key to continue...
    set MSG_RUNNING=Running installer...
    set MSG_ERROR=There was a problem during installation.
    set MSG_PRESS_EXIT=Press a key to exit
    set MSG_COMPLETE=Installation completed.
    set MSG_PRESS_FINISH=Press a key to finish
)

color 0B
cls

echo.
echo ============================================================
echo   %TITLE%
echo ============================================================
echo.
echo %MSG_CONFIG%
echo.
echo %MSG_PRESS%
pause > nul

REM Ejecutar el instalador PowerShell
echo.
echo %MSG_RUNNING%
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0install.ps1"

if errorlevel 1 (
    echo.
    echo [ERROR] %MSG_ERROR%
    echo.
    pause
    exit /b 1
)

echo.
echo %MSG_COMPLETE%
echo.
pause
