@echo off
REM Script de despliegue para Reaper Live Remote
REM Copia los archivos de webroot a la carpeta de REAPER

echo ========================================
echo   Reaper Live Remote - Despliegue
echo ========================================
echo.

REM Detectar carpeta de REAPER
set REAPER_DIR=%APPDATA%\REAPER\reaper_www_root

echo Carpeta de destino: %REAPER_DIR%
echo.

REM Verificar si existe la carpeta
if not exist "%REAPER_DIR%" (
    echo [ERROR] No se encuentra la carpeta de REAPER
    echo.
    echo Por favor, verifica que REAPER este instalado o crea la carpeta manualmente:
    echo %REAPER_DIR%
    echo.
    pause
    exit /b 1
)

REM Crear backup (opcional)
if exist "%REAPER_DIR%\index.html" (
    echo Se ha encontrado una instalacion previa.
    echo.
    set /p BACKUP="Deseas hacer backup? (S/N): "
    if /i "%BACKUP%"=="S" (
        set BACKUP_DIR=%REAPER_DIR%_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
        set BACKUP_DIR=!BACKUP_DIR: =0!
        echo.
        echo Creando backup en: !BACKUP_DIR!
        xcopy /E /I /Y "%REAPER_DIR%" "!BACKUP_DIR!" > nul
        echo [OK] Backup creado
        echo.
    )
)

REM Copiar archivos
echo Copiando archivos...
echo.

xcopy /E /I /Y "webroot\*" "%REAPER_DIR%" > nul

if %errorlevel% == 0 (
    echo.
    echo ========================================
    echo   [OK] Archivos copiados correctamente
    echo ========================================
    echo.
    echo Archivos copiados a: %REAPER_DIR%
    echo.
    echo Proximos pasos:
    echo 1. Abre REAPER
    echo 2. Ve a Opciones ^> Preferencias ^> Control/OSC/Web
    echo 3. Marca "Enable web interface"
    echo 4. Configura puerto (8080) y contrasena
    echo 5. Desde tu tablet, abre http://TU_IP:8080
    echo.
) else (
    echo.
    echo [ERROR] Hubo un problema al copiar los archivos
    echo.
)

pause
