# ============================================================
# REAPER Live Remote - Instalador Automatico
# ============================================================
# Este script instala automaticamente todo lo necesario:
# 1. SWS Extension (si no esta instalada)
# 2. Script Lua en REAPER
# 3. Archivos web en reaper_www_root
# 4. Configura el Command ID automaticamente
# ============================================================

param(
    [switch]$SkipSWS = $false  # Usar -SkipSWS para omitir instalacion de SWS
)

$ErrorActionPreference = "Stop"

# Colores y formato
function Write-Title {
    param($Text)
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param($Text)
    Write-Host "[OK] $Text" -ForegroundColor Green
}

function Write-Info {
    param($Text)
    Write-Host "[i] $Text" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param($Text)
    Write-Host "[ERROR] $Text" -ForegroundColor Red
}

function Write-Step {
    param($Text)
    Write-Host ""
    Write-Host "> $Text" -ForegroundColor Cyan
}

# ============================================================
# PASO 0: Verificaciones iniciales
# ============================================================

Write-Title "REAPER Live Remote - Instalador Automatico"

Write-Info "Este instalador configurara automaticamente:"
Write-Host "  - SWS Extension (si no esta instalada)" -ForegroundColor White
Write-Host "  - Script Lua de control de saltos" -ForegroundColor White
Write-Host "  - Interfaz web en REAPER" -ForegroundColor White
Write-Host "  - Configuracion automatica del Command ID" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Deseas continuar? (S/N)"
if ($continue -ne "S" -and $continue -ne "s") {
    Write-Host "Instalacion cancelada." -ForegroundColor Yellow
    exit 0
}

# Verificar que REAPER este instalado
Write-Step "Verificando instalacion de REAPER..."

# 1. Intentar detectar si REAPER está en ejecución (Ruta más fiable)
$reaperProcess = Get-Process reaper -ErrorAction SilentlyContinue
$reaperRunningDir = $null
if ($reaperProcess) {
    try {
        $reaperRunningDir = Split-Path $reaperProcess.Path -Parent
        Write-Info "REAPER detectado en ejecucion en: $reaperRunningDir"
    } catch {}
}

# 2. Intentar detectar vía Registro de Windows
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\REAPER",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\REAPER",
    "HKCU:\Software\REAPER"
)

$regFoundPaths = @()
foreach ($regPath in $registryPaths) {
    if (Test-Path $regPath) {
        $val = Get-ItemProperty -Path $regPath -Name "InstallLocation", "Path" -ErrorAction SilentlyContinue
        if ($val.InstallLocation) { $regFoundPaths += $val.InstallLocation }
        if ($val.Path) { $regFoundPaths += $val.Path }
    }
}

# 3. Lista de rutas posibles (Priorizando la que está en ejecución y carpetas de recursos)
$reaperPaths = @(
    $reaperRunningDir,                                # 1. Carpeta del proceso activo
    "$env:APPDATA\REAPER"                             # 2. Carpeta de recursos estándar
) + $regFoundPaths + @(                               # 3. Rutas encontradas en registro
    "$env:ProgramFiles\REAPER",                       # 4. Carpeta de programa (64-bit)
    "$env:ProgramFiles(x86)\REAPER",                  # 5. Carpeta de programa (32-bit)
    "C:\REAPER",                                      # 6. Rutas comunes
    "D:\REAPER"                                       # 7. Ruta en disco D (común para músicos)
) | Where-Object { $_ -ne $null } | Select-Object -Unique

$reaperDir = $null
$foundPaths = @()

foreach ($path in $reaperPaths) {
    if (Test-Path $path) {
        # Una carpeta de REAPER válida debe tener reaper.ini o ser la carpeta de instalación
        if (Test-Path "$path\reaper.ini") {
            $foundPaths += $path
        } elseif (Test-Path "$path\reaper.exe") {
            # Si es la carpeta del EXE, verificar si es portable (reaper.ini está ahí)
            # o si los recursos están en AppData (en cuyo caso esta ruta no es la de recursos)
            if (Test-Path "$path\reaper.ini") {
                $foundPaths += $path
            }
        }
    }
}

# Eliminar duplicados y limpiar rutas
$foundPaths = $foundPaths | Select-Object -Unique

if ($foundPaths.Count -gt 1) {
    Write-Info "Se han encontrado varias posibles carpetas de REAPER:"
    for ($i = 0; $i -lt $foundPaths.Count; $i++) {
        $type = "Recursos/Configuracion"
        if (Test-Path "$($foundPaths[$i])\reaper.exe") { $type = "Instalacion Portable" }
        if ($foundPaths[$i] -like "*AppData*") { $type = "Instalacion Estandar (AppData)" }
        
        Write-Host "  [$($i+1)] $($foundPaths[$i]) ($type)" -ForegroundColor White
    }
    Write-Host ""
    $choice = Read-Host "Cual deseas usar? (1-$($foundPaths.Count))"
    if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $foundPaths.Count) {
        $reaperDir = $foundPaths[[int]$choice - 1]
    } else {
        $reaperDir = $foundPaths[0]
    }
} elseif ($foundPaths.Count -eq 1) {
    $reaperDir = $foundPaths[0]
}

# Si no se detectó nada, preguntar al usuario
if (-not $reaperDir) {
    Write-Info "No se pudo detectar la carpeta de REAPER automáticamente."
    $manualPath = Read-Host "Por favor, pega la ruta de tu carpeta de REAPER (donde está reaper.ini)"
    if (Test-Path $manualPath) {
        $reaperDir = $manualPath
    }
}

if (-not $reaperDir) {
    Write-Error-Custom "No se encontro REAPER instalado en tu sistema."
    Write-Host ""
    Write-Host "Por favor, instala REAPER desde: https://www.reaper.fm" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Success "Carpeta de REAPER detectada: $reaperDir"

# Detectar carpetas de destino basadas en la carpeta de recursos
$scriptsDir = "$reaperDir\Scripts"
$wwwDir = "$reaperDir\reaper_www_root"
$userPluginsDir = "$reaperDir\UserPlugins"
$kbFile = "$reaperDir\reaper-kb.ini"

# Función para intentar encontrar el Command ID automáticamente
function Get-ScriptCommandID {
    if (Test-Path $kbFile) {
        Write-Info "Buscando Command ID en reaper-kb.ini..."
        $kbContent = Get-Content $kbFile
        # Buscar la línea que contiene nuestro script
        # Formato: SCR 4 0 RS... "smooth_seeking_control_v3.lua" smooth_seeking_control_v3.lua
        $line = $kbContent | Select-String "smooth_seeking_control_v3.lua" | Select-Object -First 1
        
        if ($line -and $line.ToString() -match 'RS[a-f0-9]{40}') {
            $id = $matches[0]
            return "_$id" # Añadir el prefijo necesario para la Web API
        }
    }
    return $null
}

# ============================================================
# PASO 1: Verificar/Instalar SWS Extension
# ============================================================

Write-Step "Verificando SWS Extension..."

$swsInstalled = $false

# Lista de posibles ubicaciones de la DLL de SWS
$swsDlls = @(
    "$userPluginsDir\reaper_sws64.dll",
    "$userPluginsDir\reaper_sws.dll",
    "$env:APPDATA\REAPER\UserPlugins\reaper_sws64.dll",
    "$env:APPDATA\REAPER\UserPlugins\reaper_sws.dll",
    "$env:ProgramFiles\REAPER\UserPlugins\reaper_sws64.dll"
)

# Archivos de configuración que solo existen si SWS está instalado
$swsConfigFiles = @(
    "$reaperDir\sws-autocoloricon.ini",
    "$reaperDir\SWS.ini",
    "$env:APPDATA\REAPER\sws-autocoloricon.ini"
)

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

if ($swsInstalled) {
    Write-Success "SWS Extension detectada (vía: $foundSwsPath)"
} else {
    Write-Info "SWS Extension no detectada en las rutas habituales"
    
    if ($SkipSWS) {
        Write-Info "Saltando instalacion de SWS (modo -SkipSWS)"
        Write-Host ""
        Write-Host "NOTA: Los modos de salto avanzados no funcionaran sin SWS." -ForegroundColor Yellow
        Write-Host "Puedes instalar SWS manualmente desde: https://www.sws-extension.org" -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "SWS Extension es necesaria para los modos de salto avanzados." -ForegroundColor Yellow
        Write-Host ""
        
        $installSWS = Read-Host "Deseas descargar e instalar SWS ahora? (S/N)"
        
        if ($installSWS -eq "S" -or $installSWS -eq "s") {
            Write-Info "Abriendo pagina de descarga de SWS Extension..."
            Write-Host ""
            Write-Host "Por favor:" -ForegroundColor Yellow
            Write-Host "1. Descarga el instalador para tu version de Windows" -ForegroundColor White
            Write-Host "2. Ejecuta el instalador" -ForegroundColor White
            Write-Host "3. Reinicia REAPER si esta abierto" -ForegroundColor White
            Write-Host "4. Vuelve aqui y presiona Enter para continuar" -ForegroundColor White
            Write-Host ""
            
            Start-Process "https://www.sws-extension.org/download/pre-release/"
            
            Read-Host "Presiona Enter cuando hayas instalado SWS"
            
            # Verificar de nuevo
            if ((Test-Path $swsDll) -or (Test-Path $swsDll32)) {
                Write-Success "SWS Extension instalada correctamente"
                $swsInstalled = $true
            } else {
                Write-Info "No se detecto SWS, pero continuaremos con la instalacion"
                Write-Host "(Puedes instalarla mas tarde desde: https://www.sws-extension.org)" -ForegroundColor Gray
            }
        } else {
            Write-Info "Saltando instalacion de SWS"
            Write-Host "(Puedes instalarla mas tarde desde: https://www.sws-extension.org)" -ForegroundColor Gray
        }
    }
}

# ============================================================
# PASO 2: Copiar archivos web a reaper_www_root
# ============================================================

Write-Step "Instalando interfaz web..."

# Crear directorio si no existe
if (-not (Test-Path $wwwDir)) {
    New-Item -ItemType Directory -Force -Path $wwwDir | Out-Null
    Write-Info "Carpeta creada: $wwwDir"
}

# Backup si ya existe
if (Test-Path "$wwwDir\index.html") {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupDir = "$wwwDir`_backup_$timestamp"
    
    Write-Info "Encontrada instalacion previa, creando backup..."
    Copy-Item -Path $wwwDir -Destination $backupDir -Recurse -Force
    Write-Success "Backup creado en: $backupDir"
}

# Copiar archivos
Copy-Item -Path "webroot\*" -Destination $wwwDir -Recurse -Force
Write-Success "Archivos web instalados en: $wwwDir"

# ============================================================
# PASO 3: Copiar script Lua a carpeta de Scripts
# ============================================================

Write-Step "Instalando script Lua de control..."

# Crear directorio si no existe
if (-not (Test-Path $scriptsDir)) {
    New-Item -ItemType Directory -Force -Path $scriptsDir | Out-Null
    Write-Info "Carpeta de scripts creada: $scriptsDir"
}

$luaScript = "reaper-scripts\smooth_seeking_control_v3.lua"
$destLuaScript = "$scriptsDir\smooth_seeking_control_v3.lua"

# NUEVA LÓGICA: Detectar si el script ya está registrado en una ruta distinta para actualizar el archivo CORRECTO
if (Test-Path $kbFile) {
    Write-Info "Verificando ruta de registro en REAPER..."
    $kbContent = Get-Content $kbFile
    # Buscar la línea del script y extraer la ruta entre comillas
    $line = $kbContent | Select-String "smooth_seeking_control_v3.lua" | Select-Object -First 1
    if ($line -and $line.ToString() -match '"([^"]+\.lua)"') {
        $registeredPath = $matches[1]
        # Si la ruta no es absoluta, REAPER la busca en la carpeta Scripts
        if (-not [System.IO.Path]::IsPathRooted($registeredPath)) {
            $fullRegisteredPath = Join-Path $scriptsDir $registeredPath
        } else {
            $fullRegisteredPath = $registeredPath
        }
        
        if (Test-Path $fullRegisteredPath) {
            $destLuaScript = $fullRegisteredPath
            Write-Info "REAPER está usando este archivo: $destLuaScript"
        }
    }
}

if (Test-Path $luaScript) {
    Copy-Item -Path $luaScript -Destination $destLuaScript -Force
    Write-Success "Script Lua actualizado correctamente en: $destLuaScript"
} else {
    Write-Error-Custom "No se encontro el script Lua en: $luaScript"
    exit 1
}

# ============================================================
# PASO 4: Configurar REAPER
# ============================================================

Write-Step "Configuracion del Command ID..."

# Intentar detección automática primero
$commandId = Get-ScriptCommandID

if ($commandId) {
    Write-Success "Command ID detectado automaticamente: $commandId"
} else {
    Write-Info "No se pudo detectar el Command ID automaticamente."
    Write-Host ""
    Write-Host "Necesitamos registrar el script en REAPER para obtener su ID." -ForegroundColor Yellow
    Write-Host "Por favor, sigue estos pasos:" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "1. Abre REAPER (si no esta abierto)" -ForegroundColor White
    Write-Host ""

    $openReaper = Read-Host "REAPER esta abierto? (S/N)"
    if ($openReaper -ne "S" -and $openReaper -ne "s") {
        Write-Info "Intentando abrir REAPER..."
        
        $reaperExe = "$env:ProgramFiles\REAPER\reaper.exe"
        if (-not (Test-Path $reaperExe)) {
            $reaperExe = "$env:ProgramFiles(x86)\REAPER\reaper.exe"
        }
        
        if (Test-Path $reaperExe) {
            Start-Process $reaperExe
            Write-Success "REAPER iniciado"
            Start-Sleep -Seconds 3
        } else {
            Write-Info "Abre REAPER manualmente y continua"
        }
    }

    Write-Host ""
    Write-Host "2. En REAPER:" -ForegroundColor White
    Write-Host "   - Presiona Shift + / (o ve a Actions → Show action list)" -ForegroundColor Gray
    Write-Host "   - Haz clic en 'New action...' → 'Load ReaScript...'" -ForegroundColor Gray
    Write-Host "   - Selecciona el archivo:" -ForegroundColor Gray
    Write-Host "     $destLuaScript" -ForegroundColor Cyan
    Write-Host ""

    Read-Host "Presiona Enter cuando hayas cargado el script"

    Write-Host ""
    Write-Host "3. Ahora copia el Command ID del script:" -ForegroundColor White
    Write-Host "   - En la lista de acciones, busca 'smooth_seeking_control_v3'" -ForegroundColor Gray
    Write-Host "   - Veras un ID como: _RS7D3C92BC..." -ForegroundColor Gray
    Write-Host "   - Selecciona ese ID y copialo (Ctrl+C)" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Pega el Command ID aqui (o presiona Enter para saltar):" -ForegroundColor Yellow
    $commandId = Read-Host "Command ID"
}

if ([string]::IsNullOrWhiteSpace($commandId)) {
    Write-Info "No se proporciono un Command ID. Se mantendra la configuracion actual."
} else {
    # Configurar Command ID en state.js
    Write-Step "Actualizando Command ID en state.js..."
    
    $stateFile = "$wwwDir\js\state.js"
    
    if (Test-Path $stateFile) {
        $content = Get-Content $stateFile -Raw
        
        # Reemplazar tanto si es null como si tiene otro ID anterior
        $pattern = 'smoothSeekingScriptCmd:\s*[^,]+'
        $replacement = "smoothSeekingScriptCmd: '$commandId'"
        
        $newContent = $content -replace $pattern, $replacement
        
        Set-Content -Path $stateFile -Value $newContent -Encoding UTF8
        
        Write-Success "Command ID configurado correctamente en state.js"
    } else {
        Write-Error-Custom "No se encontro el archivo state.js en $wwwDir"
    }
}

# ============================================================
# PASO 5: Instrucciones finales
# ============================================================

Write-Title "Instalacion completada!"

Write-Success "Todos los archivos han sido instalados correctamente"
Write-Host ""

Write-Host "============================================================" -ForegroundColor Yellow
Write-Host "  uLTIMO PASO: Configurar servidor web en REAPER" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. En REAPER, ve a:" -ForegroundColor White
Write-Host "   Preferences → Control/OSC/Web" -ForegroundColor Cyan
Write-Host ""

Write-Host "2. Marca la casilla:" -ForegroundColor White
Write-Host "   [X] Enable web interface" -ForegroundColor Cyan
Write-Host ""

Write-Host "3. Configura:" -ForegroundColor White
Write-Host "   - Puerto: 8080" -ForegroundColor Cyan
Write-Host "   - Usuario: (opcional, para seguridad)" -ForegroundColor Cyan
Write-Host "   - Contrasena: (opcional, para seguridad)" -ForegroundColor Cyan
Write-Host ""

Write-Host "4. Haz clic en OK" -ForegroundColor White
Write-Host ""

Write-Host "============================================================" -ForegroundColor Green
Write-Host "  Como conectar desde tu tablet?" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Tu IP local es:" -ForegroundColor Yellow
$localIP = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -like "192.168.*"} | Select-Object -First 1

if ($localIP) {
    $ipAddress = $localIP.IPAddress
    Write-Host "  http://$ipAddress`:8080" -ForegroundColor Cyan -BackgroundColor Black
    Write-Host ""
    Write-Host "En tu tablet:" -ForegroundColor White
    Write-Host "  1. Conectate a la misma red WiFi" -ForegroundColor Gray
    Write-Host "  2. Abre el navegador" -ForegroundColor Gray
    Write-Host "  3. Ve a: http://$ipAddress`:8080" -ForegroundColor Gray
} else {
    Write-Host "  No se pudo detectar automaticamente" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Para encontrar tu IP:" -ForegroundColor White
    Write-Host "  1. Abre CMD" -ForegroundColor Gray
    Write-Host "  2. Ejecuta: ipconfig" -ForegroundColor Gray
    Write-Host "  3. Busca 'IPv4 Address' (algo como 192.168.x.x)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "  Documentacion y soporte" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "README.md - Guia completa de uso" -ForegroundColor White
Write-Host "docs/ - Documentacion tecnica" -ForegroundColor White
Write-Host ""

Write-Host "Listo para tocar en vivo!" -ForegroundColor Green
Write-Host ""

Read-Host "Presiona Enter para salir"

