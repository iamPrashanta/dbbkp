#!/bin/bash
set -e

DBBKP_INSTALL_PATH="/usr/local/bin/dbbkp"
INFRA_INSTALL_PATH="/usr/local/bin/infra-agent"

DBBKP_RAW_URL="https://raw.githubusercontent.com/iamPrashanta/dbbkp/main/dbbkp.sh"
INFRA_RAW_URL="https://raw.githubusercontent.com/iamPrashanta/dbbkp/main/infra-agent.sh"

echo "Installing dbbkp pipeline and infra-agent..."

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

curl -fsSL "$DBBKP_RAW_URL" -o "$DBBKP_INSTALL_PATH"
chmod +x "$DBBKP_INSTALL_PATH"
echo "✔ dbbkp installed at $DBBKP_INSTALL_PATH"

curl -fsSL "$INFRA_RAW_URL" -o "$INFRA_INSTALL_PATH"
chmod +x "$INFRA_INSTALL_PATH"
echo "✔ infra-agent installed at $INFRA_INSTALL_PATH"

echo ""
echo "Installation complete!"
echo "Commands available:"
echo "  dbbkp           - Run the backup pipeline"
echo "  infra-agent     - Run the infrastructure security agent"
