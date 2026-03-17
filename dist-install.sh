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

# Function to locate binaries
locate_binaries() {
    CLI_BIN=""
    GUI_BIN=""
    
    # Check current directory first (prebuilt release scenario)
    if [ -f "library-loader-cli" ] && [ -f "library-loader-gui" ]; then
        CLI_BIN="library-loader-cli"
        GUI_BIN="library-loader-gui"
        echo "Found binaries in current directory"
        
        # Verify binary integrity (if checksums exist)
        if [ -f "library-loader-cli.sha256" ]; then
            echo "Verifying CLI binary integrity..."
            sha256sum -c library-loader-cli.sha256
        fi
        
        if [ -f "library-loader-gui.sha256" ]; then
            echo "Verifying GUI binary integrity..."
            sha256sum -c library-loader-gui.sha256
        fi
        
        return 0
    fi
    
    # Check target/release (built from source scenario)
    if [ -f "target/release/library-loader-cli" ] && [ -f "target/release/library-loader-gui" ]; then
        CLI_BIN="target/release/library-loader-cli"
        GUI_BIN="target/release/library-loader-gui"
        echo "Found binaries in target/release/"
        return 0
    fi
    
    # Binaries not found, provide helpful error message
    echo "Error: Unable to locate binaries"
    echo ""
    echo "Please either:"
    echo "  1. Build the project: cargo build --release"
    echo "  2. Download prebuilt binaries from: https://github.com/ZaviiNet/library-loader/releases"
    return 1
}

# Locate the binaries
if ! locate_binaries; then
    exit 1
fi

# Copy binaries
cp "${CLI_BIN}" /usr/bin/library-loader-cli
cp "${GUI_BIN}" /usr/bin/library-loader-gui

# Install desktop file if it exists
DESKTOP_FILE=""
if [ -f "library-loader-gui.desktop" ]; then
    DESKTOP_FILE="library-loader-gui.desktop"
elif [ -f "ll-gui/library-loader-gui.desktop" ]; then
    DESKTOP_FILE="ll-gui/library-loader-gui.desktop"
fi

if [ -n "${DESKTOP_FILE}" ]; then
    desktop-file-install "${DESKTOP_FILE}"
fi

# Install icon if it exists
ICON_FILE=""
if [ -f "library-loader-icon.svg" ]; then
    ICON_FILE="library-loader-icon.svg"
elif [ -f "ll-gui/assets/library-loader-icon.svg" ]; then
    ICON_FILE="ll-gui/assets/library-loader-icon.svg"
fi

if [ -n "${ICON_FILE}" ]; then
    cp "${ICON_FILE}" /usr/share/icons/hicolor/scalable/apps/net.olback.LibraryLoader.svg
    
    # Update icon cache if gtk-update-icon-cache is available
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true
    fi
fi

echo "Done"
