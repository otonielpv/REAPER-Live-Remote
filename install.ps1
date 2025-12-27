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

# Detectar idioma del sistema
$Culture = (Get-Culture).Name
$IsSpanish = $Culture -like 'es-*'

# Mensajes en español
$SpanishMessages = @{
    'title' = "REAPER Live Remote - Instalador Automático"
    'info_setup' = "Este instalador configurará automáticamente:"
    'sws_ext' = "SWS Extension (si no está instalada)"
    'lua_script' = "Script Lua de control de saltos"
    'web_interface' = "Interfaz web en REAPER"
    'command_id' = "Configuración automática del Command ID"
    'checking_reaper' = "Verificando instalación de REAPER..."
    'reaper_running' = "REAPER detectado en ejecución en:"
    'multiple_reaper' = "Se han encontrado varias carpetas de REAPER:"
    'select_reaper' = "Selecciona la carpeta de REAPER a usar (1-{0}):"
    'auto_detect_failed' = "No se pudo detectar la carpeta de REAPER automáticamente."
    'manual_path' = "Introduce la ruta completa a la carpeta de recursos de REAPER:"
    'reaper_not_found' = "No se encontró REAPER instalado en tu sistema."
    'reaper_detected' = "Carpeta de REAPER detectada:"
    'checking_command_id' = "Buscando Command ID en reaper-kb.ini..."
    'checking_sws' = "Verificando SWS Extension..."
    'sws_detected' = "SWS Extension detectada (vía:"
    'sws_not_detected' = "SWS Extension no detectada en las rutas habituales"
    'skipping_sws' = "Saltando instalación de SWS (modo -SkipSWS)"
    'downloading_sws' = "Abriendo página de descarga de SWS Extension..."
    'sws_installed' = "SWS Extension instalada correctamente"
    'sws_not_detected_continue' = "No se detectó SWS, pero continuaremos con la instalación"
    'continue_prompt' = "¿Deseas continuar? (S/N)"
    'installation_cancelled' = "Instalación cancelada."
    'sws_note' = "NOTA: Los modos de salto avanzados no funcionaran sin SWS."
    'sws_manual_install' = "Puedes instalar SWS manualmente desde: https://www.sws-extension.org"
    'sws_required' = "SWS Extension es necesaria para los modos de salto avanzados."
    'please_do' = "Por favor:"
    'download_installer' = "1. Descarga el instalador para tu version de Windows"
    'run_installer' = "2. Ejecuta el instalador"
    'restart_reaper' = "3. Reinicia REAPER si esta abierto"
    'come_back' = "4. Vuelve aqui y presiona Enter para continuar"
    'press_enter_after_sws' = "Presiona Enter cuando hayas instalado SWS"
    'sws_not_detected_continue_short' = "No se detecto SWS, pero continuaremos con la instalacion"
    'sws_skipping_short' = "Saltando instalacion de SWS"
    'can_install_later' = "(Puedes instalarla mas tarde desde: https://www.sws-extension.org)"
    'installing_web' = "Instalando interfaz web..."
    'folder_created' = "Carpeta creada:"
    'previous_install_found' = "Encontrada instalacion previa, creando backup..."
    'backup_created' = "Backup creado en:"
    'web_files_installed' = "Archivos web instalados en:"
    'installing_lua' = "Instalando script Lua de control..."
    'scripts_folder_created' = "Carpeta de scripts creada:"
    'verifying_registration' = "Verificando ruta de registro en REAPER..."
    'reaper_using_file' = "REAPER está usando este archivo:"
    'lua_updated' = "Script Lua actualizado correctamente en:"
    'lua_not_found' = "No se encontro el script Lua en:"
    'configuring_command_id' = "Configuracion del Command ID..."
    'command_id_auto_detected' = "Command ID detectado automaticamente:"
    'command_id_manual' = "No se pudo detectar el Command ID automaticamente."
    'need_register_script' = "Necesitamos registrar el script en REAPER para obtener su ID."
    'please_follow_steps' = "Por favor, sigue estos pasos:"
    'open_reaper' = "1. Abre REAPER (si no esta abierto)"
    'is_reaper_open' = "REAPER esta abierto? (S/N)"
    'trying_open_reaper' = "Intentando abrir REAPER..."
    'reaper_started' = "REAPER iniciado"
    'open_manually' = "Abre REAPER manualmente y continua"
    'in_reaper' = "2. En REAPER:"
    'press_shift_slash' = "   - Presiona Shift + / (o ve a Actions → Show action list)"
    'click_new_action' = "   - Haz clic en 'New action...' → 'Load ReaScript...'"
    'select_file' = "   - Selecciona el archivo:"
    'press_enter_after_loaded' = "Presiona Enter cuando hayas cargado el script"
    'copy_command_id' = "3. Ahora copia el Command ID del script:"
    'search_smooth' = "   - En la lista de acciones, busca 'smooth_seeking_control_v3'"
    'see_id_like' = "   - Veras un ID como: _RS7D3C92BC..."
    'select_copy' = "   - Selecciona ese ID y copialo (Ctrl+C)"
    'paste_command_id' = "Pega el Command ID aqui (o presiona Enter para saltar):"
    'no_command_id' = "No se proporciono un Command ID. Se mantendra la configuracion actual."
    'updating_command_id' = "Actualizando Command ID en state.js..."
    'command_id_configured' = "Command ID configurado correctamente en state.js"
    'state_js_not_found' = "No se encontro el archivo state.js en"
    'installation_completed' = "Instalacion completada!"
    'all_files_installed' = "Todos los archivos han sido instalados correctamente"
    'last_step' = "uLTIMO PASO: Configurar servidor web en REAPER"
    'go_to' = "1. En REAPER, ve a:"
    'preferences_control' = "   Preferences → Control/OSC/Web"
    'check_box' = "2. Marca la casilla:"
    'enable_web' = "   [X] Enable web interface"
    'configure' = "3. Configura:"
    'port' = "   - Puerto: 8080"
    'user_optional' = "   - Usuario: (opcional, para seguridad)"
    'password_optional' = "   - Contrasena: (opcional, para seguridad)"
    'click_ok' = "4. Haz clic en OK"
    'how_to_connect' = "Como conectar desde tu tablet?"
    'your_local_ip' = "Tu IP local es:"
    'on_your_tablet' = "En tu tablet:"
    'connect_same_wifi' = "  1. Conectate a la misma red WiFi"
    'open_browser' = "  2. Abre el navegador"
    'go_to_ip' = "  3. Ve a:"
    'could_not_detect_ip' = "  No se pudo detectar automaticamente"
    'to_find_ip' = "Para encontrar tu IP:"
    'open_cmd' = "  1. Abre CMD"
    'run_ipconfig' = "  2. Ejecuta: ipconfig"
    'look_for_ipv4' = "  3. Busca 'IPv4 Address' (algo como 192.168.x.x)"
    'documentation_support' = "Documentacion y soporte"
    'readme_guide' = "README.md - Guia completa de uso"
    'docs_technical' = "docs/ - Documentacion tecnica"
    'ready_live' = "Listo para tocar en vivo!"
    'press_enter_exit' = "Presiona Enter para salir"
    'install_reaper_from' = "Por favor, instala REAPER desde: https://www.reaper.fm"
}

# Mensajes en inglés
$EnglishMessages = @{
    'title' = "REAPER Live Remote - Automatic Installer"
    'info_setup' = "This installer will automatically configure:"
    'sws_ext' = "SWS Extension (if not installed)"
    'lua_script' = "Lua script for jump control"
    'web_interface' = "Web interface in REAPER"
    'command_id' = "Automatic Command ID configuration"
    'checking_reaper' = "Checking REAPER installation..."
    'reaper_running' = "REAPER detected running at:"
    'multiple_reaper' = "Multiple REAPER folders found:"
    'select_reaper' = "Select REAPER folder to use (1-{0}):"
    'auto_detect_failed' = "Could not auto-detect REAPER folder."
    'manual_path' = "Enter the full path to REAPER resource folder:"
    'reaper_not_found' = "REAPER not found installed on your system."
    'reaper_detected' = "REAPER folder detected:"
    'checking_command_id' = "Looking for Command ID in reaper-kb.ini..."
    'checking_sws' = "Checking SWS Extension..."
    'sws_detected' = "SWS Extension detected (via:"
    'sws_not_detected' = "SWS Extension not detected in usual paths"
    'skipping_sws' = "Skipping SWS installation (-SkipSWS mode)"
    'downloading_sws' = "Opening SWS Extension download page..."
    'sws_installed' = "SWS Extension installed successfully"
    'sws_not_detected_continue' = "SWS not detected, but continuing with installation"
    'continue_prompt' = "Do you want to continue? (Y/N)"
    'installation_cancelled' = "Installation cancelled."
    'sws_note' = "NOTE: Advanced jump modes will not work without SWS."
    'sws_manual_install' = "You can install SWS manually from: https://www.sws-extension.org"
    'sws_required' = "SWS Extension is required for advanced jump modes."
    'please_do' = "Please:"
    'download_installer' = "1. Download the installer for your Windows version"
    'run_installer' = "2. Run the installer"
    'restart_reaper' = "3. Restart REAPER if it is open"
    'come_back' = "4. Come back here and press Enter to continue"
    'press_enter_after_sws' = "Press Enter when you have installed SWS"
    'sws_not_detected_continue_short' = "SWS not detected, but continuing with installation"
    'sws_skipping_short' = "Skipping SWS installation"
    'can_install_later' = "(You can install it later from: https://www.sws-extension.org)"
    'installing_web' = "Installing web interface..."
    'folder_created' = "Folder created:"
    'previous_install_found' = "Previous installation found, creating backup..."
    'backup_created' = "Backup created at:"
    'web_files_installed' = "Web files installed at:"
    'installing_lua' = "Installing Lua control script..."
    'scripts_folder_created' = "Scripts folder created:"
    'verifying_registration' = "Verifying registration path in REAPER..."
    'reaper_using_file' = "REAPER is using this file:"
    'lua_updated' = "Lua script updated successfully at:"
    'lua_not_found' = "Lua script not found at:"
    'configuring_command_id' = "Configuring Command ID..."
    'command_id_auto_detected' = "Command ID auto-detected:"
    'command_id_manual' = "Could not auto-detect Command ID."
    'need_register_script' = "We need to register the script in REAPER to get its ID."
    'please_follow_steps' = "Please follow these steps:"
    'open_reaper' = "1. Open REAPER (if not already open)"
    'is_reaper_open' = "Is REAPER open? (Y/N)"
    'trying_open_reaper' = "Trying to open REAPER..."
    'reaper_started' = "REAPER started"
    'open_manually' = "Open REAPER manually and continue"
    'in_reaper' = "2. In REAPER:"
    'press_shift_slash' = "   - Press Shift + / (or go to Actions → Show action list)"
    'click_new_action' = "   - Click 'New action...' → 'Load ReaScript...'"
    'select_file' = "   - Select the file:"
    'press_enter_after_loaded' = "Press Enter when you have loaded the script"
    'copy_command_id' = "3. Now copy the Command ID of the script:"
    'search_smooth' = "   - In the actions list, search for 'smooth_seeking_control_v3'"
    'see_id_like' = "   - You will see an ID like: _RS7D3C92BC..."
    'select_copy' = "   - Select that ID and copy it (Ctrl+C)"
    'paste_command_id' = "Paste the Command ID here (or press Enter to skip):"
    'no_command_id' = "No Command ID provided. Current configuration will be kept."
    'updating_command_id' = "Updating Command ID in state.js..."
    'command_id_configured' = "Command ID configured correctly in state.js"
    'state_js_not_found' = "state.js file not found in"
    'installation_completed' = "Installation completed!"
    'all_files_installed' = "All files have been installed successfully"
    'last_step' = "LAST STEP: Configure web server in REAPER"
    'go_to' = "1. In REAPER, go to:"
    'preferences_control' = "   Preferences → Control/OSC/Web"
    'check_box' = "2. Check the box:"
    'enable_web' = "   [X] Enable web interface"
    'configure' = "3. Configure:"
    'port' = "   - Port: 8080"
    'user_optional' = "   - User: (optional, for security)"
    'password_optional' = "   - Password: (optional, for security)"
    'click_ok' = "4. Click OK"
    'how_to_connect' = "How to connect from your tablet?"
    'your_local_ip' = "Your local IP is:"
    'on_your_tablet' = "On your tablet:"
    'connect_same_wifi' = "  1. Connect to the same WiFi network"
    'open_browser' = "  2. Open the browser"
    'go_to_ip' = "  3. Go to:"
    'could_not_detect_ip' = "  Could not detect automatically"
    'to_find_ip' = "To find your IP:"
    'open_cmd' = "  1. Open CMD"
    'run_ipconfig' = "  2. Run: ipconfig"
    'look_for_ipv4' = "  3. Look for 'IPv4 Address' (something like 192.168.x.x)"
    'documentation_support' = "Documentation and support"
    'readme_guide' = "README.md - Complete usage guide"
    'docs_technical' = "docs/ - Technical documentation"
    'ready_live' = "Ready to play live!"
    'press_enter_exit' = "Press Enter to exit"
    'install_reaper_from' = "Please install REAPER from: https://www.reaper.fm"
}

$Messages = if ($IsSpanish) { $SpanishMessages } else { $EnglishMessages }

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

Write-Title $Messages['title']

Write-Info $Messages['info_setup']
Write-Host "  - $($Messages['sws_ext'])" -ForegroundColor White
Write-Host "  - $($Messages['lua_script'])" -ForegroundColor White
Write-Host "  - $($Messages['web_interface'])" -ForegroundColor White
Write-Host "  - $($Messages['command_id'])" -ForegroundColor White
Write-Host ""

$continue = Read-Host $Messages['continue_prompt']
if ( ($IsSpanish -and $continue -ne "S" -and $continue -ne "s") -or (-not $IsSpanish -and $continue -ne "Y" -and $continue -ne "y") ) {
    Write-Host $Messages['installation_cancelled'] -ForegroundColor Yellow
    exit 0
}

# Verificar que REAPER este instalado
Write-Step $Messages['checking_reaper']

# 1. Intentar detectar si REAPER está en ejecución (Ruta más fiable)
$reaperProcess = Get-Process reaper -ErrorAction SilentlyContinue
$reaperRunningDir = $null
if ($reaperProcess) {
    try {
        $reaperRunningDir = Split-Path $reaperProcess.Path -Parent
        Write-Info "$($Messages['reaper_running']) $reaperRunningDir"
    } catch {}
}

# 2. Lista de rutas posibles (Priorizando la que está en ejecución y carpetas de recursos)
$reaperPaths = @(
    $reaperRunningDir,                                # 1. Carpeta del proceso activo
    "$env:APPDATA\REAPER",                            # 2. Carpeta de recursos estándar
    "$env:ProgramFiles\REAPER",                       # 3. Carpeta de programa (64-bit)
    "$env:ProgramFiles(x86)\REAPER",                  # 4. Carpeta de programa (32-bit)
    "C:\REAPER"                                       # 5. Ruta común de instalaciones portables
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
            # o si los recursos están en AppData
            if (Test-Path "$path\reaper.ini") {
                $foundPaths += $path
            }
        }
    }
}

if ($foundPaths.Count -gt 1) {
    Write-Info $Messages['multiple_reaper']
    for ($i = 0; $i -lt $foundPaths.Count; $i++) {
        Write-Host "  [$($i+1)] $($foundPaths[$i])" -ForegroundColor White
    }
    $choice = Read-Host ([string]::Format($Messages['select_reaper'], $foundPaths.Count))
    if ($choice -match '^\d+$' -and [int]$choice -le $foundPaths.Count) {
        $reaperDir = $foundPaths[[int]$choice - 1]
    } else {
        $reaperDir = $foundPaths[0]
    }
} elseif ($foundPaths.Count -eq 1) {
    $reaperDir = $foundPaths[0]
}

# Si no se detectó nada, preguntar al usuario
if (-not $reaperDir) {
    Write-Info $Messages['auto_detect_failed']
    $manualPath = Read-Host $Messages['manual_path']
    if (Test-Path $manualPath) {
        $reaperDir = $manualPath
    }
}

if (-not $reaperDir) {
    Write-Error-Custom $Messages['reaper_not_found']
    Write-Host ""
    Write-Host $Messages['install_reaper_from'] -ForegroundColor Yellow
    Write-Host ""
    Read-Host $Messages['press_enter_exit']
    exit 1
}

Write-Success "$($Messages['reaper_detected']) $reaperDir"

# Detectar carpetas de destino basadas en la carpeta de recursos
$scriptsDir = "$reaperDir\Scripts"
$wwwDir = "$reaperDir\reaper_www_root"
$userPluginsDir = "$reaperDir\UserPlugins"
$kbFile = "$reaperDir\reaper-kb.ini"

# Función para intentar encontrar el Command ID automáticamente
function Get-ScriptCommandID {
    if (Test-Path $kbFile) {
        Write-Info $Messages['checking_command_id']
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

Write-Step $Messages['checking_sws']

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
    Write-Success "$($Messages['sws_detected']) $foundSwsPath)"
} else {
    Write-Info $Messages['sws_not_detected']
    
    if ($SkipSWS) {
        Write-Info $Messages['skipping_sws']
        Write-Host ""
        Write-Host $Messages['sws_note'] -ForegroundColor Yellow
        Write-Host $Messages['sws_manual_install'] -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host $Messages['sws_required'] -ForegroundColor Yellow
        Write-Host ""
        
        $installSWS = Read-Host $Messages['continue_prompt']
        
        if ( ($IsSpanish -and $installSWS -eq "S" -or $installSWS -eq "s") -or (-not $IsSpanish -and $installSWS -eq "Y" -or $installSWS -eq "y") ) {
            Write-Info $Messages['downloading_sws']
            Write-Host ""
            Write-Host $Messages['please_do'] -ForegroundColor Yellow
            Write-Host $Messages['download_installer'] -ForegroundColor White
            Write-Host $Messages['run_installer'] -ForegroundColor White
            Write-Host $Messages['restart_reaper'] -ForegroundColor White
            Write-Host $Messages['come_back'] -ForegroundColor White
            Write-Host ""
            
            Start-Process "https://www.sws-extension.org/download/pre-release/"
            
            Read-Host $Messages['press_enter_after_sws']
            
            # Verificar de nuevo
            if ((Test-Path $swsDll) -or (Test-Path $swsDll32)) {
                Write-Success $Messages['sws_installed']
                $swsInstalled = $true
            } else {
                Write-Info $Messages['sws_not_detected_continue_short']
                Write-Host $Messages['can_install_later'] -ForegroundColor Gray
            }
        } else {
            Write-Info $Messages['sws_skipping_short']
            Write-Host $Messages['can_install_later'] -ForegroundColor Gray
        }
    }
}

# ============================================================
# PASO 2: Copiar archivos web a reaper_www_root
# ============================================================

Write-Step $Messages['installing_web']

# Crear directorio si no existe
if (-not (Test-Path $wwwDir)) {
    New-Item -ItemType Directory -Force -Path $wwwDir | Out-Null
    Write-Info "$($Messages['folder_created']) $wwwDir"
}

# Backup si ya existe
if (Test-Path "$wwwDir\index.html") {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupDir = "$wwwDir`_backup_$timestamp"
    
    Write-Info $Messages['previous_install_found']
    Copy-Item -Path $wwwDir -Destination $backupDir -Recurse -Force
    Write-Success "$($Messages['backup_created']) $backupDir"
}

# Copiar archivos
Copy-Item -Path "webroot\*" -Destination $wwwDir -Recurse -Force
Write-Success "$($Messages['web_files_installed']) $wwwDir"

# ============================================================
# PASO 3: Copiar script Lua a carpeta de Scripts
# ============================================================

Write-Step $Messages['installing_lua']

# Crear directorio si no existe
if (-not (Test-Path $scriptsDir)) {
    New-Item -ItemType Directory -Force -Path $scriptsDir | Out-Null
    Write-Info "$($Messages['scripts_folder_created']) $scriptsDir"
}

$luaScript = "reaper-scripts\smooth_seeking_control_v3.lua"
$destLuaScript = "$scriptsDir\smooth_seeking_control_v3.lua"

# NUEVA LÓGICA: Detectar si el script ya está registrado en una ruta distinta para actualizar el archivo CORRECTO
if (Test-Path $kbFile) {
    Write-Info $Messages['verifying_registration']
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
            Write-Info "$($Messages['reaper_using_file']) $destLuaScript"
        }
    }
}

if (Test-Path $luaScript) {
    Copy-Item -Path $luaScript -Destination $destLuaScript -Force
    Write-Success "$($Messages['lua_updated']) $destLuaScript"
} else {
    Write-Error-Custom "$($Messages['lua_not_found']) $luaScript"
    exit 1
}

# ============================================================
# PASO 4: Configurar REAPER
# ============================================================

Write-Step $Messages['configuring_command_id']

# Intentar detección automática primero
$commandId = Get-ScriptCommandID

if ($commandId) {
    Write-Success "$($Messages['command_id_auto_detected']) $commandId"
} else {
    Write-Info $Messages['command_id_manual']
    Write-Host ""
    Write-Host $Messages['need_register_script'] -ForegroundColor Yellow
    Write-Host $Messages['please_follow_steps'] -ForegroundColor Yellow
    Write-Host ""

    Write-Host $Messages['open_reaper'] -ForegroundColor White
    Write-Host ""

    $openReaper = Read-Host $Messages['is_reaper_open']
    if ($openReaper -ne "S" -and $openReaper -ne "s" -and $openReaper -ne "Y" -and $openReaper -ne "y") {
        Write-Info $Messages['trying_open_reaper']
        
        $reaperExe = "$env:ProgramFiles\REAPER\reaper.exe"
        if (-not (Test-Path $reaperExe)) {
            $reaperExe = "$env:ProgramFiles(x86)\REAPER\reaper.exe"
        }
        
        if (Test-Path $reaperExe) {
            Start-Process $reaperExe
            Write-Success $Messages['reaper_started']
            Start-Sleep -Seconds 3
        } else {
            Write-Info $Messages['open_manually']
        }
    }

    Write-Host ""
    Write-Host $Messages['in_reaper'] -ForegroundColor White
    Write-Host $Messages['press_shift_slash'] -ForegroundColor Gray
    Write-Host $Messages['click_new_action'] -ForegroundColor Gray
    Write-Host "$($Messages['select_file']) $destLuaScript" -ForegroundColor Cyan
    Write-Host ""

    Read-Host $Messages['press_enter_after_loaded']

    Write-Host ""
    Write-Host $Messages['copy_command_id'] -ForegroundColor White
    Write-Host $Messages['search_smooth'] -ForegroundColor Gray
    Write-Host $Messages['see_id_like'] -ForegroundColor Gray
    Write-Host $Messages['select_copy'] -ForegroundColor Gray
    Write-Host ""

    Write-Host $Messages['paste_command_id'] -ForegroundColor Yellow
    $commandId = Read-Host "Command ID"
}

if ([string]::IsNullOrWhiteSpace($commandId)) {
    Write-Info $Messages['no_command_id']
} else {
    # Configurar Command ID en state.js
    Write-Step $Messages['updating_command_id']
    
    $stateFile = "$wwwDir\js\state.js"
    
    if (Test-Path $stateFile) {
        $content = Get-Content $stateFile -Raw
        
        # Reemplazar tanto si es null como si tiene otro ID anterior
        $pattern = 'smoothSeekingScriptCmd:\s*[^,]+'
        $replacement = "smoothSeekingScriptCmd: '$commandId'"
        
        $newContent = $content -replace $pattern, $replacement
        
        Set-Content -Path $stateFile -Value $newContent -Encoding UTF8
        
        Write-Success $Messages['command_id_configured']
    } else {
        Write-Error-Custom "$($Messages['state_js_not_found']) $wwwDir"
    }
}

# ============================================================
# PASO 5: Instrucciones finales
# ============================================================

Write-Title $Messages['installation_completed']

Write-Success $Messages['all_files_installed']
Write-Host ""

Write-Host "============================================================" -ForegroundColor Yellow
Write-Host "  $($Messages['last_step'])" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host ""

Write-Host $Messages['go_to'] -ForegroundColor White
Write-Host $Messages['preferences_control'] -ForegroundColor Cyan
Write-Host ""

Write-Host $Messages['check_box'] -ForegroundColor White
Write-Host $Messages['enable_web'] -ForegroundColor Cyan
Write-Host ""

Write-Host $Messages['configure'] -ForegroundColor White
Write-Host $Messages['port'] -ForegroundColor Cyan
Write-Host $Messages['user_optional'] -ForegroundColor Cyan
Write-Host $Messages['password_optional'] -ForegroundColor Cyan
Write-Host ""

Write-Host $Messages['click_ok'] -ForegroundColor White
Write-Host ""

Write-Host "============================================================" -ForegroundColor Green
Write-Host "  $($Messages['how_to_connect'])" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

Write-Host $Messages['your_local_ip'] -ForegroundColor Yellow

# Obtener todas las IPs IPv4, excluyendo Loopback
$allIPs = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object -ExpandProperty IPAddress

if ($allIPs) {
    # Si es un array, mostrar todas; si es un string, convertir a array
    if ($allIPs -is [string]) {
        $allIPs = @($allIPs)
    }
    
    foreach ($ip in $allIPs) {
        Write-Host "  http://$ip`:8080" -ForegroundColor Cyan -BackgroundColor Black
    }
    
    Write-Host ""
    Write-Host $Messages['on_your_tablet'] -ForegroundColor White
    Write-Host $Messages['connect_same_wifi'] -ForegroundColor Gray
    Write-Host $Messages['open_browser'] -ForegroundColor Gray
    
    # Mostrar instrucción para la primera IP (o todas si hay varias)
    if ($allIPs.Count -gt 1) {
        Write-Host "$($Messages['go_to_ip']) (usa cualquiera de las IPs listadas arriba)" -ForegroundColor Gray
    } else {
        Write-Host "$($Messages['go_to_ip']) http://$($allIPs[0])`:8080" -ForegroundColor Gray
    }
} else {
    Write-Host $Messages['could_not_detect_ip'] -ForegroundColor Yellow
    Write-Host ""
    Write-Host $Messages['to_find_ip'] -ForegroundColor White
    Write-Host $Messages['open_cmd'] -ForegroundColor Gray
    Write-Host $Messages['run_ipconfig'] -ForegroundColor Gray
    Write-Host $Messages['look_for_ipv4'] -ForegroundColor Gray
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "  $($Messages['documentation_support'])" -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Host ""
Write-Host $Messages['readme_guide'] -ForegroundColor White
Write-Host $Messages['docs_technical'] -ForegroundColor White
Write-Host ""

Write-Host $Messages['ready_live'] -ForegroundColor Green
Write-Host ""

Read-Host $Messages['press_enter_exit']
exit 0
