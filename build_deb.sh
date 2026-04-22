#!/bin/bash

# ==============================================================================
# dbbkp - Automated Debian Package (.deb) Builder
# ==============================================================================
# Usage: ./build_deb.sh [version]
# Example: ./build_deb.sh 1.0.5

VERSION=${1:-"1.0.0"}
PACKAGE_NAME="dbbkp_${VERSION}_all"

echo "========================================="
echo " Building Debian Package: $PACKAGE_NAME"
echo "========================================="

# Ensure dpkg-deb is available
if ! command -v dpkg-deb &> /dev/null; then
    echo "[!] Error: 'dpkg-deb' is not installed on this system."
    echo "[i] If you are on Ubuntu/Debian/WSL, install it via: sudo apt install dpkg"
    exit 1
fi

if [ ! -f "dbbkp.sh" ]; then
    echo "[!] Error: 'dbbkp.sh' not found in the current directory."
    exit 1
fi

echo "[i] Preparing package layout in Linux native /tmp to bypass Windows NTFS permissions..."
BUILD_DIR="/tmp/$PACKAGE_NAME"

# 1. Clean previous build dirs if they exist
rm -rf "$BUILD_DIR"
rm -f "${PACKAGE_NAME}.deb"
rm -f "/tmp/${PACKAGE_NAME}.deb"

# 2. Create strict Debian directory structure
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$BUILD_DIR/usr/bin"

# Enforce strict POSIX permissions for Debian dpkg
chmod 755 "$BUILD_DIR"
chmod 755 "$BUILD_DIR/DEBIAN"

# 3. Generate the metadata control file
cat <<EOF > "$BUILD_DIR/DEBIAN/control"
Package: dbbkp
Version: $VERSION
Architecture: all
Maintainer: Prashanta <iloveprashanta@gmail.com>
Depends: bash, curl
Recommends: mysql-client | default-mysql-client | mariadb-client, postgresql-client, awscli, rclone, pv
Description: Automated Database Backup & Disaster Recovery Agent
 A powerful, dual-mode Bash CLI utility to fully automate MySQL and 
 PostgreSQL lifecycle management, restores, and cloud syncing.
EOF
chmod 644 "$BUILD_DIR/DEBIAN/control"

# 4. Copy the script over and lock its permissions
cp dbbkp.sh "$BUILD_DIR/usr/bin/dbbkp"
chmod 755 "$BUILD_DIR/usr/bin/dbbkp"

# 5. Compile the .deb package in the native Linux path
echo "[i] Compiling .deb package..."
dpkg-deb --build "$BUILD_DIR"

# 6. Move the package back to the Windows Desktop folder and cleanup
mv "/tmp/${PACKAGE_NAME}.deb" "./${PACKAGE_NAME}.deb"
rm -rf "$BUILD_DIR"

echo ""
echo "[+] SUCCESS! Package created: ${PACKAGE_NAME}.deb"
echo "[i] You can now upload this to an APT Repo or install it manually:"
echo "    sudo apt install ./${PACKAGE_NAME}.deb"
