#!/bin/bash

# ============================================================
# REAPER Live Remote - Simple Installer for Mac/Linux
# ============================================================

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Detect language
LANG_CODE=$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1 2>/dev/null || echo "en")
if [ "$LANG_CODE" = "es" ]; then
    TITLE="REAPER Live Remote - Instalador Mac/Linux"
    ERROR_REAPER_NOT_FOUND="Carpeta de recursos de REAPER no encontrada en:"
    PLEASE_INSTALL_REAPER="Asegúrate de que REAPER esté instalado y se haya ejecutado al menos una vez."
    REAPER_FOUND="REAPER encontrado en:"
    INSTALLING_WEB="Instalando interfaz web..."
    WEB_COPIED="Archivos web copiados a:"
    INSTALLING_SCRIPT="Instalando script Lua..."
    SCRIPT_COPIED="Script copiado a:"
    DETECTING_COMMAND_ID="Detectando Command ID..."
    COMMAND_ID_DETECTED="Command ID detectado:"
    STATE_UPDATED="state.js actualizado con Command ID."
    SCRIPT_NOT_REGISTERED="Script no registrado en REAPER aún."
    INSTALLATION_COMPLETE="Instalación completada!"
    NEXT_STEPS="Próximos pasos:"
    OPEN_REAPER="Abre REAPER"
    LOAD_SCRIPT="Acciones → Cargar ReaScript → Selecciona smooth_seeking_control_v3.lua"
    COPY_COMMAND_ID="Copia el Command ID y pégalo en:"
    CONFIGURE_WEB="Preferencias → Control/OSC/Web → Añade 'Interfaz de navegador web'"
    SET_PORT="Establece el puerto en 8080"
    ACCESS_FROM_TABLET="Accede desde tu tablet en:"
else
    TITLE="REAPER Live Remote - Mac/Linux Installer"
    ERROR_REAPER_NOT_FOUND="REAPER resource folder not found at:"
    PLEASE_INSTALL_REAPER="Please make sure REAPER is installed and has been run at least once."
    REAPER_FOUND="REAPER found at:"
    INSTALLING_WEB="Installing Web Interface..."
    WEB_COPIED="Web files copied to:"
    INSTALLING_SCRIPT="Installing Lua Script..."
    SCRIPT_COPIED="Script copied to:"
    DETECTING_COMMAND_ID="Detecting Command ID..."
    COMMAND_ID_DETECTED="Detected Command ID:"
    STATE_UPDATED="state.js updated with Command ID."
    SCRIPT_NOT_REGISTERED="Script not registered in REAPER yet."
    INSTALLATION_COMPLETE="Installation Complete!"
    NEXT_STEPS="Next Steps:"
    OPEN_REAPER="Open REAPER"
    LOAD_SCRIPT="Actions → Load ReaScript → Select smooth_seeking_control_v3.lua"
    COPY_COMMAND_ID="Copy the Command ID and paste it in:"
    CONFIGURE_WEB="Preferences → Control/OSC/Web → Add 'Web browser interface'"
    SET_PORT="Set Port to 8080"
    ACCESS_FROM_TABLET="Access from your tablet at:"
fi

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  $TITLE${NC}"
echo -e "${CYAN}============================================================${NC}"

# 1. Detect REAPER Resource Path
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    REAPER_PATH="$HOME/Library/Application Support/REAPER"
else
    # Linux
    REAPER_PATH="$HOME/.config/REAPER"
fi

if [ ! -d "$REAPER_PATH" ]; then
    echo -e "${RED}[ERROR] $ERROR_REAPER_NOT_FOUND $REAPER_PATH${NC}"
    echo -e "${YELLOW}$PLEASE_INSTALL_REAPER${NC}"
    exit 1
fi

echo -e "${GREEN}[OK] $REAPER_FOUND $REAPER_PATH${NC}"

# 2. Define destinations
WWW_DEST="$REAPER_PATH/reaper_www_root"
SCRIPTS_DEST="$REAPER_PATH/Scripts"

# 3. Copy Web Files
echo -e "\n${CYAN}> $INSTALLING_WEB${NC}"
mkdir -p "$WWW_DEST"
cp -R webroot/* "$WWW_DEST/"
echo -e "${GREEN}[OK] $WEB_COPIED $WWW_DEST${NC}"

# 4. Copy Lua Script
echo -e "\n${CYAN}> $INSTALLING_SCRIPT${NC}"
mkdir -p "$SCRIPTS_DEST"
cp reaper-scripts/smooth_seeking_control_v3.lua "$SCRIPTS_DEST/"
echo -e "${GREEN}[OK] $SCRIPT_COPIED $SCRIPTS_DEST${NC}"

# 5. Try to auto-detect Command ID
echo -e "\n${CYAN}> $DETECTING_COMMAND_ID${NC}"
KB_FILE="$REAPER_PATH/reaper-kb.ini"
COMMAND_ID=""

if [ -f "$KB_FILE" ]; then
    # Search for the script in reaper-kb.ini
    # Format: SCR 4 0 RS... "smooth_seeking_control_v3.lua"
    RAW_ID=$(grep "smooth_seeking_control_v3.lua" "$KB_FILE" | grep -oE "RS[a-f0-9]{40}" | head -n 1)
    if [ ! -z "$RAW_ID" ]; then
        COMMAND_ID="_$RAW_ID"
        echo -e "${GREEN}[OK] $COMMAND_ID_DETECTED $COMMAND_ID${NC}"
        
        # Update state.js
        STATE_FILE="$WWW_DEST/js/state.js"
        if [ -f "$STATE_FILE" ]; then
            # Use sed to replace the command ID
            # macOS sed needs an empty string for -i
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s/smoothSeekingScriptCmd: .*/smoothSeekingScriptCmd: '$COMMAND_ID',/" "$STATE_FILE"
            else
                sed -i "s/smoothSeekingScriptCmd: .*/smoothSeekingScriptCmd: '$COMMAND_ID',/" "$STATE_FILE"
            fi
            echo -e "${GREEN}[OK] $STATE_UPDATED${NC}"
        fi
    else
        echo -e "${YELLOW}[i] $SCRIPT_NOT_REGISTERED${NC}"
    fi
fi

# 6. Final Instructions
echo -e "\n${CYAN}============================================================${NC}"
echo -e "${GREEN}  $INSTALLATION_COMPLETE${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e "\n${YELLOW}$NEXT_STEPS${NC}"
echo -e "1. $OPEN_REAPER"
if [ -z "$COMMAND_ID" ]; then
    echo -e "2. $LOAD_SCRIPT"
    echo -e "3. $COPY_COMMAND_ID $WWW_DEST/js/state.js"
fi
echo -e "4. $CONFIGURE_WEB"
echo -e "5. $SET_PORT"

# Get local IP
if [[ "$OSTYPE" == "darwin"* ]]; then
    IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1)
else
    IP=$(hostname -I | awk '{print $1}')
fi

echo -e "\n${GREEN}$ACCESS_FROM_TABLET http://$IP:8080${NC}\n"
