#!/bin/bash

set -e

# User-local installation script for Bazzite and other immutable/read-only filesystems
# This script installs Library Loader to ~/.local/bin and ~/.local/share

echo "Library Loader - User-Local Installation"
echo "=========================================="
echo ""

# Determine installation directories
BIN_DIR="${HOME}/.local/bin"
SHARE_DIR="${HOME}/.local/share"
APPLICATIONS_DIR="${SHARE_DIR}/applications"
ICONS_DIR="${SHARE_DIR}/icons/hicolor/scalable/apps"

# Create directories if they don't exist
mkdir -p "${BIN_DIR}"
mkdir -p "${APPLICATIONS_DIR}"
mkdir -p "${ICONS_DIR}"

# Verify binaries exist
if [ ! -f "library-loader-cli" ]; then
    echo "Error: library-loader-cli not found in current directory"
    exit 1
fi

if [ ! -f "library-loader-gui" ]; then
    echo "Error: library-loader-gui not found in current directory"
    exit 1
fi

# Verify binary integrity (if checksums exist)
if [ -f "library-loader-cli.sha256" ]; then
    echo "Verifying CLI binary integrity..."
    sha256sum -c library-loader-cli.sha256
fi

if [ -f "library-loader-gui.sha256" ]; then
    echo "Verifying GUI binary integrity..."
    sha256sum -c library-loader-gui.sha256
fi

echo ""
echo "Installing binaries to ${BIN_DIR}..."

# Copy binaries
cp library-loader-cli "${BIN_DIR}/"
cp library-loader-gui "${BIN_DIR}/"

# Make binaries executable
chmod +x "${BIN_DIR}/library-loader-cli"
chmod +x "${BIN_DIR}/library-loader-gui"

echo "✓ Binaries installed"

# Install desktop file if it exists
if [ -f "library-loader-gui.desktop" ]; then
    echo "Installing desktop integration..."
    
    # Copy and update desktop file to use full path
    sed "s|Exec=library-loader-gui|Exec=${BIN_DIR}/library-loader-gui|g" \
        library-loader-gui.desktop > "${APPLICATIONS_DIR}/library-loader-gui.desktop"
    
    chmod +x "${APPLICATIONS_DIR}/library-loader-gui.desktop"
    echo "✓ Desktop file installed"
fi

# Install icon if it exists
if [ -f "library-loader-icon.svg" ]; then
    cp library-loader-icon.svg "${ICONS_DIR}/net.olback.LibraryLoader.svg"
    echo "✓ Icon installed"
    
    # Update icon cache if gtk-update-icon-cache is available
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache "${SHARE_DIR}/icons/hicolor" 2>/dev/null || true
        echo "✓ Icon cache updated"
    fi
fi

echo ""
echo "Installation complete!"
echo ""
echo "IMPORTANT: Make sure ${BIN_DIR} is in your PATH"
echo ""

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" == *":${BIN_DIR}:"* ]]; then
    echo "✓ ${BIN_DIR} is already in your PATH"
else
    echo "⚠ ${BIN_DIR} is NOT in your PATH"
    echo ""
    echo "Add the following to your ~/.bashrc or ~/.zshrc:"
    echo ""
    echo "    export PATH=\"\${HOME}/.local/bin:\${PATH}\""
    echo ""
    echo "Then restart your terminal or run: source ~/.bashrc"
fi

echo ""
echo "You can now run:"
echo "  - library-loader-cli"
echo "  - library-loader-gui"
echo ""
