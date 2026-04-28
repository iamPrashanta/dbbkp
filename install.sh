#!/bin/bash
set -e

INSTALL_PATH="/usr/local/bin/dbbkp"
RAW_URL="https://raw.githubusercontent.com/iamPrashanta/dbbkp/main/dbbkp.sh"

echo "Installing dbbkp..."

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

curl -fsSL "$RAW_URL" -o "$INSTALL_PATH"

chmod +x "$INSTALL_PATH"

echo "Installed successfully!"
echo "Run: dbbkp"
