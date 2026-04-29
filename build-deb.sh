#!/bin/bash
# Script to build a Debian package (.deb) for dbbkp and infra-agent

VERSION="2.0.0"
PKG_NAME="dbbkp-suite"
PKG_DIR="${PKG_NAME}_${VERSION}_all"

echo "Building Debian Package: $PKG_DIR.deb..."

# Create directory structure
mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/local/bin"

# Create the control file
cat <<EOF > "$PKG_DIR/DEBIAN/control"
Package: $PKG_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: all
Maintainer: iamPrashanta
Description: Database Backup Pipeline and Infrastructure Agent
 A comprehensive toolkit for database backups, restores, file transfers,
 and infrastructure security scanning.
EOF

# Copy the scripts
cp dbbkp.sh "$PKG_DIR/usr/local/bin/dbbkp"
cp infra-agent.sh "$PKG_DIR/usr/local/bin/infra-agent"

# Set executable permissions
chmod 755 "$PKG_DIR/usr/local/bin/dbbkp"
chmod 755 "$PKG_DIR/usr/local/bin/infra-agent"

# Build the .deb file
if command -v dpkg-deb >/dev/null; then
    dpkg-deb --build "$PKG_DIR"
    echo "Package built successfully: ${PKG_DIR}.deb"
    echo "You can install it using: sudo dpkg -i ${PKG_DIR}.deb"
else
    echo "Error: dpkg-deb is not installed. You need to run this on a Debian/Ubuntu based system."
fi

# Clean up build directory
rm -rf "$PKG_DIR"
