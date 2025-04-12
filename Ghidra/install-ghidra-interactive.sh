#!/bin/bash

set -e

echo "=== Ghidra Installer for Kali Linux ==="

# Prompt to install JDK
read -p "Install OpenJDK 23? [Y/n]: " INSTALL_JDK
INSTALL_JDK=${INSTALL_JDK:-Y}

if [[ "$INSTALL_JDK" =~ ^[Yy]$ ]]; then
    echo "[*] Installing OpenJDK 23..."
    sudo apt update
    sudo apt install -y openjdk-23-jdk wget unzip
else
    echo "[*] Skipping JDK installation."
fi

# Ask for installation path
read -p "Enter Ghidra installation path [default: /usr/bin/ghidra]: " INSTALL_PATH
INSTALL_PATH=${INSTALL_PATH:-/usr/bin/ghidra}

# Fetch latest Ghidra release
echo "[*] Fetching latest Ghidra release info..."
GHIDRA_API_URL="https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest"
GHIDRA_JSON=$(curl -s "$GHIDRA_API_URL")

GHIDRA_URL=$(echo "$GHIDRA_JSON" | grep browser_download_url | grep PUBLIC_ | cut -d '"' -f 4)
GHIDRA_FILENAME=$(basename "$GHIDRA_URL")
GHIDRA_VERSION=$(echo "$GHIDRA_FILENAME" | cut -d '_' -f 2)

echo "[*] Downloading Ghidra $GHIDRA_VERSION..."
wget -q --show-progress "$GHIDRA_URL"

echo "[*] Installing to: $INSTALL_PATH"
sudo mkdir -p "$INSTALL_PATH"
sudo unzip -q "$GHIDRA_FILENAME" -d "$INSTALL_PATH"
sudo rm "$GHIDRA_FILENAME"

GHIDRA_DIR="$INSTALL_PATH/ghidra_${GHIDRA_VERSION}_PUBLIC"
GHIDRA_EXEC="$GHIDRA_DIR/ghidraRun"

echo "[*] Making Ghidra executable..."
sudo chmod +x "$GHIDRA_EXEC"

# Ask about desktop shortcut
read -p "Create desktop shortcut? [Y/n]: " CREATE_SHORTCUT
CREATE_SHORTCUT=${CREATE_SHORTCUT:-Y}

if [[ "$CREATE_SHORTCUT" =~ ^[Yy]$ ]]; then
    echo "[*] Creating desktop shortcut..."
    DESKTOP_FILE="$HOME/Desktop/Ghidra.desktop"
    ICON_PATH="$GHIDRA_DIR/docs/GhidraClass/Beginner/Images/GhidraLogo64.png"

    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Icon=$ICON_PATH
Exec=$GHIDRA_EXEC
Name=Ghidra
EOF

    chmod +x "$DESKTOP_FILE"
    echo "[+] Shortcut created at $DESKTOP_FILE"
else
    echo "[*] Skipping shortcut creation."
fi

echo -e "\n[+] Ghidra $GHIDRA_VERSION installed successfully at $GHIDRA_DIR"
