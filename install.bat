@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

REM ============================================================
REM REAPER Live Remote - Instalador Rápido
REM ============================================================

color 0B
cls

echo.
echo ============================================================
echo   REAPER Live Remote - Instalador Automático
echo ============================================================
echo.
echo Este instalador configurará todo automáticamente.
echo.
echo Presiona cualquier tecla para continuar...
pause > nul

REM Ejecutar el instalador PowerShell
echo.
echo Ejecutando instalador...
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0install.ps1"

if errorlevel 1 (
    echo.
    echo [ERROR] Hubo un problema durante la instalación.
    echo.
    pause
    exit /b 1
)

echo.
echo Instalación completada.
echo.
pause
