# ============================================================
# REAPER Live Remote - Verificador de Instalación
# ============================================================
# Este script verifica que todo esté correctamente instalado
# ============================================================

$ErrorActionPreference = "Continue"

function Write-Title {
    param($Text)
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Check {
    param($Text, $Status)
    if ($Status) {
        Write-Host "[✓] $Text" -ForegroundColor Green
    } else {
        Write-Host "[✗] $Text" -ForegroundColor Red
    }
}

function Write-Info {
    param($Text)
    Write-Host "[i] $Text" -ForegroundColor Yellow
}

# Variables
$appDataDir = "$env:APPDATA\REAPER"
$programFilesDir = "$env:ProgramFiles\REAPER"
$programFilesX86Dir = "$env:ProgramFiles(x86)\REAPER"

# Intentar detectar si REAPER está en ejecución para encontrar su ruta
$reaperProcess = Get-Process reaper -ErrorAction SilentlyContinue
$reaperRunningDir = $null
if ($reaperProcess) {
    try {
        $reaperRunningDir = Split-Path $reaperProcess.Path -Parent
    } catch {}
}

# Lista de posibles carpetas de recursos de REAPER
$potentialResourceDirs = @(
    $appDataDir,
    $reaperRunningDir,
    $programFilesDir,
    $programFilesX86Dir,
    "C:\REAPER"
) | Where-Object { $_ -ne $null -and (Test-Path $_) } | Select-Object -Unique

# Encontrar la carpeta de recursos real (la que tiene reaper.ini o carpetas clave)
$resourceDir = $appDataDir # Default
foreach ($dir in $potentialResourceDirs) {
    if (Test-Path "$dir\reaper.ini") {
        $resourceDir = $dir
        break
    }
}

$wwwDir = "$resourceDir\reaper_www_root"
$scriptsDir = "$resourceDir\Scripts"
$userPluginsDir = "$resourceDir\UserPlugins"

Write-Title "Verificador de Instalación - REAPER Live Remote"
Write-Info "Carpeta de recursos detectada: $resourceDir"

$allGood = $true

# ============================================================
# 1. Verificar archivos web
# ============================================================

Write-Host "1. Archivos de interfaz web" -ForegroundColor Cyan
Write-Host ""

$indexHtml = Test-Path "$wwwDir\index.html"
$songHtml = Test-Path "$wwwDir\song.html"
$stateJs = Test-Path "$wwwDir\js\state.js"
$apiJs = Test-Path "$wwwDir\js\api.js"
$cssApp = Test-Path "$wwwDir\css\app.css"

Write-Check "index.html instalado" $indexHtml
Write-Check "song.html instalado" $songHtml
Write-Check "js/state.js instalado" $stateJs
Write-Check "js/api.js instalado" $apiJs
Write-Check "css/app.css instalado" $cssApp

if (-not ($indexHtml -and $songHtml -and $stateJs -and $apiJs -and $cssApp)) {
    $allGood = $false
}

# ============================================================
# 2. Verificar script Lua
# ============================================================

Write-Host ""
Write-Host "2. Script Lua de control" -ForegroundColor Cyan
Write-Host ""

$luaScript = Test-Path "$scriptsDir\smooth_seeking_control_v3.lua"

Write-Check "smooth_seeking_control_v3.lua instalado" $luaScript

if (-not $luaScript) {
    $allGood = $false
    Write-Info "Ubicación esperada: $scriptsDir\smooth_seeking_control_v3.lua"
}

# ============================================================
# 3. Verificar SWS Extension
# ============================================================

Write-Host ""
Write-Host "3. SWS Extension" -ForegroundColor Cyan
Write-Host ""

# Buscar SWS en múltiples ubicaciones posibles
$swsDlls = @(
    "$userPluginsDir\reaper_sws64.dll",
    "$userPluginsDir\reaper_sws.dll",
    "$env:APPDATA\REAPER\UserPlugins\reaper_sws64.dll",
    "$env:APPDATA\REAPER\UserPlugins\reaper_sws.dll",
    "$env:ProgramFiles\REAPER\UserPlugins\reaper_sws64.dll",
    "$env:ProgramFiles(x86)\REAPER\UserPlugins\reaper_sws64.dll"
)

# Archivos de configuración que solo existen si SWS está instalado
$swsConfigFiles = @(
    "$resourceDir\sws-autocoloricon.ini",
    "$resourceDir\SWS.ini",
    "$env:APPDATA\REAPER\sws-autocoloricon.ini"
)

$swsInstalled = $false
foreach ($dll in $swsDlls) {
    if (Test-Path $dll) {
        $swsInstalled = $true
        $foundSwsPath = $dll
        break
    }
}

# Si no se encontró la DLL, buscar archivos de configuración
if (-not $swsInstalled) {
    foreach ($ini in $swsConfigFiles) {
        if (Test-Path $ini) {
            $swsInstalled = $true
            $foundSwsPath = $ini
            break
        }
    }
}

Write-Check "SWS Extension instalada" $swsInstalled

if ($swsInstalled) {
    Write-Info "Detectada vía: $foundSwsPath"
} else {
    Write-Info "SWS Extension es opcional pero recomendada para modos de salto avanzados"
    Write-Info "Descargar desde: https://www.sws-extension.org"
}

# ============================================================
# 4. Verificar Command ID en state.js
# ============================================================

Write-Host ""
Write-Host "4. Configuración de Command ID" -ForegroundColor Cyan
Write-Host ""

if (Test-Path "$wwwDir\js\state.js") {
    $stateContent = Get-Content "$wwwDir\js\state.js" -Raw
    
    if ($stateContent -match "smoothSeekingScriptCmd:\s*'(_RS[A-F0-9]+)'") {
        $commandId = $matches[1]
        Write-Check "Command ID configurado: $commandId" $true
    } elseif ($stateContent -match "smoothSeekingScriptCmd:\s*null") {
        Write-Check "Command ID configurado" $false
        $allGood = $false
        Write-Info "Ejecuta el instalador para configurar el Command ID automáticamente"
    } else {
        Write-Check "Command ID no encontrado en state.js" $false
        $allGood = $false
    }
} else {
    Write-Check "state.js no encontrado" $false
    $allGood = $false
}

# ============================================================
# 5. Verificar conectividad
# ============================================================

Write-Host ""
Write-Host "5. Prueba de conectividad" -ForegroundColor Cyan
Write-Host ""

Write-Info "Intentando conectar al servidor web de REAPER..."

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 5 -ErrorAction Stop
    Write-Check "Servidor web de REAPER respondiendo" $true
    Write-Info "La aplicación está accesible en: http://localhost:8080"
} catch {
    Write-Check "Servidor web de REAPER respondiendo" $false
    Write-Info "El servidor no está activo. ¿Has configurado el servidor web en REAPER?"
    Write-Info "Ve a: Preferences → Control/OSC/Web → Enable web interface"
}

# ============================================================
# 6. Mostrar IP local
# ============================================================

Write-Host ""
Write-Host "6. Información de red" -ForegroundColor Cyan
Write-Host ""

$localIP = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -like "192.168.*"} | Select-Object -First 1

if ($localIP) {
    $ipAddress = $localIP.IPAddress
    Write-Host "Tu IP local es: " -NoNewline -ForegroundColor Yellow
    Write-Host "$ipAddress" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Para conectar desde tu tablet, abre:" -ForegroundColor Yellow
    Write-Host "  http://$ipAddress`:8080" -ForegroundColor Cyan -BackgroundColor Black
} else {
    Write-Info "No se pudo detectar la IP local automáticamente"
    Write-Host "Ejecuta 'ipconfig' en CMD para ver tu IP" -ForegroundColor Gray
}

# ============================================================
# Resumen final
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor $(if ($allGood) { "Green" } else { "Yellow" })
if ($allGood) {
    Write-Host "  ✓ Instalación completa y correcta" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Hay algunos problemas que resolver" -ForegroundColor Yellow
}
Write-Host "============================================================" -ForegroundColor $(if ($allGood) { "Green" } else { "Yellow" })
Write-Host ""

if ($allGood) {
    Write-Host "¡Todo está listo! Pasos finales:" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Asegúrate de que el servidor web está activo en REAPER" -ForegroundColor White
    Write-Host "   (Preferences → Control/OSC/Web → Enable web interface)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Abre tu tablet y ve a:" -ForegroundColor White
    if ($localIP) {
        Write-Host "   http://$($localIP.IPAddress):8080" -ForegroundColor Cyan
    } else {
        Write-Host "   http://TU-IP:8080" -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Host "3. ¡Empieza a tocar! 🎸" -ForegroundColor White
} else {
    Write-Host "Por favor, corrige los problemas marcados con [✗]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Si necesitas ayuda:" -ForegroundColor White
    Write-Host "  • Ejecuta: .\install.ps1" -ForegroundColor Gray
    Write-Host "  • Lee: INSTALL.md" -ForegroundColor Gray
    Write-Host "  • Consulta: docs\server-setup.md" -ForegroundColor Gray
}

Write-Host ""
Read-Host "Presiona Enter para salir"
