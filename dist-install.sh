#!/bin/bash

set -e

# System-wide installation script (requires root/sudo)
# For user-local installation on Bazzite/Silverblue, use user-install.sh instead

if [ $UID != 0 ]; then
    echo "Error: System-wide installation requires root privileges"
    echo ""
    echo "Options:"
    echo "  1. Run with sudo: sudo ./dist-install.sh"
    echo "  2. Use user-local installation (recommended for Bazzite/Silverblue):"
    echo "     ./user-install.sh"
    echo ""
    exit 1
fi

# Verify binaries
sha256sum -c library-loader-cli.sha256
sha256sum -c library-loader-gui.sha256

# Copy binaries
cp library-loader-cli /usr/bin
cp library-loader-gui /usr/bin

# Copy desktop file & icon
desktop-file-install library-loader-gui.desktop
cp library-loader-icon.svg /usr/share/icons/hicolor/scalable/apps/net.olback.LibraryLoader.svg
gtk-update-icon-cache /usr/share/icons/hicolor

echo "Done"
