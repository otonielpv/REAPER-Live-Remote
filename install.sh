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

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  REAPER Live Remote - Mac/Linux Installer${NC}"
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
    echo -e "${RED}[ERROR] REAPER resource folder not found at: $REAPER_PATH${NC}"
    echo -e "${YELLOW}Please make sure REAPER is installed and has been run at least once.${NC}"
    exit 1
fi

echo -e "${GREEN}[OK] REAPER found at: $REAPER_PATH${NC}"

# 2. Define destinations
WWW_DEST="$REAPER_PATH/reaper_www_root"
SCRIPTS_DEST="$REAPER_PATH/Scripts"

# 3. Copy Web Files
echo -e "\n${CYAN}> Installing Web Interface...${NC}"
mkdir -p "$WWW_DEST"
cp -R webroot/* "$WWW_DEST/"
echo -e "${GREEN}[OK] Web files copied to: $WWW_DEST${NC}"

# 4. Copy Lua Script
echo -e "\n${CYAN}> Installing Lua Script...${NC}"
mkdir -p "$SCRIPTS_DEST"
cp reaper-scripts/smooth_seeking_control_v3.lua "$SCRIPTS_DEST/"
echo -e "${GREEN}[OK] Script copied to: $SCRIPTS_DEST${NC}"

# 5. Try to auto-detect Command ID
echo -e "\n${CYAN}> Detecting Command ID...${NC}"
KB_FILE="$REAPER_PATH/reaper-kb.ini"
COMMAND_ID=""

if [ -f "$KB_FILE" ]; then
    # Search for the script in reaper-kb.ini
    # Format: SCR 4 0 RS... "smooth_seeking_control_v3.lua"
    RAW_ID=$(grep "smooth_seeking_control_v3.lua" "$KB_FILE" | grep -oE "RS[a-f0-9]{40}" | head -n 1)
    if [ ! -z "$RAW_ID" ]; then
        COMMAND_ID="_$RAW_ID"
        echo -e "${GREEN}[OK] Detected Command ID: $COMMAND_ID${NC}"
        
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
            echo -e "${GREEN}[OK] state.js updated with Command ID.${NC}"
        fi
    else
        echo -e "${YELLOW}[i] Script not registered in REAPER yet.${NC}"
    fi
fi

# 6. Final Instructions
echo -e "\n${CYAN}============================================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "1. Open REAPER"
if [ -z "$COMMAND_ID" ]; then
    echo -e "2. Actions -> Load ReaScript -> Select smooth_seeking_control_v3.lua"
    echo -e "3. Copy the Command ID and paste it in: $WWW_DEST/js/state.js"
fi
echo -e "4. Preferences -> Control/OSC/Web -> Add 'Web browser interface'"
echo -e "5. Set Port to 8080"

# Get local IP
if [[ "$OSTYPE" == "darwin"* ]]; then
    IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1)
else
    IP=$(hostname -I | awk '{print $1}')
fi

echo -e "\n${GREEN}Access from your tablet at: http://$IP:8080${NC}\n"
