#!/bin/bash

set -e

# Distrobox uninstallation script for Library Loader
# Removes binaries and desktop integration installed by distrobox-install.sh

echo "Library Loader - Distrobox Uninstallation"
echo "==========================================="
echo ""

# Determine installation directories
BIN_DIR="${HOME}/.local/bin"
SHARE_DIR="${HOME}/.local/share"
APPLICATIONS_DIR="${SHARE_DIR}/applications"
ICONS_DIR="${SHARE_DIR}/icons/hicolor/scalable/apps"

# Container name
CONTAINER_NAME="library-loader-build"

echo "Removing installed files..."
echo ""

# Remove binaries
if [ -f "${BIN_DIR}/library-loader-cli" ]; then
    rm "${BIN_DIR}/library-loader-cli"
    echo "✓ Removed CLI binary"
fi

if [ -f "${BIN_DIR}/library-loader-gui" ]; then
    rm "${BIN_DIR}/library-loader-gui"
    echo "✓ Removed GUI binary"
fi

# Remove desktop file
if [ -f "${APPLICATIONS_DIR}/library-loader-gui.desktop" ]; then
    rm "${APPLICATIONS_DIR}/library-loader-gui.desktop"
    echo "✓ Removed desktop file"
fi

# Remove icon
if [ -f "${ICONS_DIR}/net.olback.LibraryLoader.svg" ]; then
    rm "${ICONS_DIR}/net.olback.LibraryLoader.svg"
    echo "✓ Removed icon"
    
    # Update icon cache if available
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache "${SHARE_DIR}/icons/hicolor" 2>/dev/null || true
        echo "✓ Icon cache updated"
    fi
fi

echo ""
echo "Uninstallation complete!"
echo ""
echo "Note: Your configuration file (~/.config/LibraryLoader.toml) was preserved."
echo "Note: Downloaded libraries in your output directories were preserved."
echo ""

# Ask about removing the container
if command -v distrobox &> /dev/null && distrobox list | grep -q "${CONTAINER_NAME}"; then
    echo "The distrobox container '${CONTAINER_NAME}' still exists."
    echo ""
    read -p "Do you want to remove the container? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing distrobox container..."
        distrobox rm -f "${CONTAINER_NAME}"
        echo "✓ Container removed"
    else
        echo "Container kept. You can remove it later with: distrobox rm ${CONTAINER_NAME}"
    fi
fi

echo ""
