#!/bin/bash

set -e

echo "[*] Installing OpenJDK 23..."
sudo apt update
sudo apt install -y openjdk-23-jdk wget unzip

# Get latest Ghidra release info from GitHub API
echo "[*] Fetching latest Ghidra release info..."
GHIDRA_API_URL="https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest"
GHIDRA_JSON=$(curl -s $GHIDRA_API_URL)

# Extract download URL and version
GHIDRA_URL=$(echo "$GHIDRA_JSON" | grep browser_download_url | grep PUBLIC_ | cut -d '"' -f 4)
GHIDRA_FILENAME=$(basename "$GHIDRA_URL")
GHIDRA_VERSION=$(echo "$GHIDRA_FILENAME" | cut -d '_' -f 2)

echo "[*] Downloading Ghidra $GHIDRA_VERSION..."
wget -q --show-progress "$GHIDRA_URL"

echo "[*] Unzipping to /usr/bin/ghidra..."
sudo mkdir -p /usr/bin/ghidra
sudo unzip -q "$GHIDRA_FILENAME" -d /usr/bin/ghidra
sudo rm "$GHIDRA_FILENAME"

GHIDRA_DIR="/usr/bin/ghidra/ghidra_${GHIDRA_VERSION}_PUBLIC"
GHIDRA_EXEC="$GHIDRA_DIR/ghidraRun"

echo "[*] Making Ghidra executable..."
sudo chmod +x "$GHIDRA_EXEC"

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

echo "[+] Ghidra $GHIDRA_VERSION installed successfully!"
echo "[+] Shortcut created on Desktop."
