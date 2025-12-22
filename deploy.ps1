# Script de despliegue para Reaper Live Remote (PowerShell)
# Copia los archivos de webroot a la carpeta de REAPER

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Reaper Live Remote - Despliegue" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Detectar carpeta de REAPER
$reaperDir = "$env:APPDATA\REAPER\reaper_www_root"

Write-Host "Carpeta de destino: $reaperDir" -ForegroundColor Yellow
Write-Host ""

# Verificar si existe la carpeta
if (-not (Test-Path $reaperDir)) {
    Write-Host "[ERROR] No se encuentra la carpeta de REAPER" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, verifica que REAPER esté instalado o crea la carpeta manualmente:" -ForegroundColor Yellow
    Write-Host $reaperDir -ForegroundColor White
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Crear backup (opcional)
if (Test-Path "$reaperDir\index.html") {
    Write-Host "Se ha encontrado una instalación previa." -ForegroundColor Yellow
    Write-Host ""
    $backup = Read-Host "¿Deseas hacer backup? (S/N)"
    
    if ($backup -eq "S" -or $backup -eq "s") {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupDir = "${reaperDir}_backup_$timestamp"
        
        Write-Host ""
        Write-Host "Creando backup en: $backupDir" -ForegroundColor Cyan
        
        Copy-Item -Path $reaperDir -Destination $backupDir -Recurse -Force
        
        Write-Host "[OK] Backup creado" -ForegroundColor Green
        Write-Host ""
    }
}

# Copiar archivos
Write-Host "Copiando archivos..." -ForegroundColor Cyan
Write-Host ""

try {
    # Crear directorio si no existe
    New-Item -ItemType Directory -Force -Path $reaperDir | Out-Null
    
    # Copiar archivos
    Copy-Item -Path "webroot\*" -Destination $reaperDir -Recurse -Force
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  [OK] Archivos copiados correctamente" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Archivos copiados a: $reaperDir" -ForegroundColor White
    Write-Host ""
    Write-Host "Próximos pasos:" -ForegroundColor Yellow
    Write-Host "1. Abre REAPER" -ForegroundColor White
    Write-Host "2. Ve a Opciones > Preferencias > Control/OSC/Web" -ForegroundColor White
    Write-Host "3. Marca 'Enable web interface'" -ForegroundColor White
    Write-Host "4. Configura puerto (8080) y contraseña" -ForegroundColor White
    Write-Host "5. Desde tu tablet, abre http://TU_IP:8080" -ForegroundColor White
    Write-Host ""
    
    # Mostrar IP local
    Write-Host "Tu IP local es:" -ForegroundColor Yellow
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object IPAddress, InterfaceAlias | Format-Table
    
} catch {
    Write-Host ""
    Write-Host "[ERROR] Hubo un problema al copiar los archivos" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
}

Read-Host "Presiona Enter para salir"
