#!/bin/bash

set -e

# User-local uninstallation script for Bazzite and other immutable/read-only filesystems

echo "Library Loader - User-Local Uninstallation"
echo "==========================================="
echo ""

# Determine installation directories
BIN_DIR="${HOME}/.local/bin"
SHARE_DIR="${HOME}/.local/share"
APPLICATIONS_DIR="${SHARE_DIR}/applications"
ICONS_DIR="${SHARE_DIR}/icons/hicolor/scalable/apps"

# Remove binaries
if [ -f "${BIN_DIR}/library-loader-cli" ]; then
    rm "${BIN_DIR}/library-loader-cli"
    echo "✓ Removed CLI binary"
else
    echo "ℹ CLI binary not found"
fi

if [ -f "${BIN_DIR}/library-loader-gui" ]; then
    rm "${BIN_DIR}/library-loader-gui"
    echo "✓ Removed GUI binary"
else
    echo "ℹ GUI binary not found"
fi

# Remove desktop file
if [ -f "${APPLICATIONS_DIR}/library-loader-gui.desktop" ]; then
    rm "${APPLICATIONS_DIR}/library-loader-gui.desktop"
    echo "✓ Removed desktop file"
else
    echo "ℹ Desktop file not found"
fi

# Remove icon
if [ -f "${ICONS_DIR}/net.olback.LibraryLoader.svg" ]; then
    rm "${ICONS_DIR}/net.olback.LibraryLoader.svg"
    echo "✓ Removed icon"
    
    # Update icon cache if gtk-update-icon-cache is available
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache "${SHARE_DIR}/icons/hicolor" 2>/dev/null || true
        echo "✓ Icon cache updated"
    fi
else
    echo "ℹ Icon not found"
fi

echo ""
echo "Uninstallation complete!"
echo ""
echo "Note: Your configuration files in ~/.config/LibraryLoader.toml"
echo "      and library data have been preserved."
echo ""
