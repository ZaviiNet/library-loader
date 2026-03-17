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

# Function to locate binaries
locate_binaries() {
    CLI_BIN=""
    GUI_BIN=""
    
    # Check current directory first (prebuilt release scenario)
    if [ -f "library-loader-cli" ]; then
        CLI_BIN="library-loader-cli"
        echo "Found CLI binary in current directory"
        
        if [ -f "library-loader-gui" ]; then
            GUI_BIN="library-loader-gui"
            echo "Found GUI binary in current directory"
        fi
        return 0
    fi
    
    # Check target/release (built from source scenario)
    if [ -f "target/release/library-loader-cli" ]; then
        CLI_BIN="target/release/library-loader-cli"
        echo "Found CLI binary in target/release/"
        
        if [ -f "target/release/library-loader-gui" ]; then
            GUI_BIN="target/release/library-loader-gui"
            echo "Found GUI binary in target/release/"
        fi
        return 0
    fi
    
    # Binaries not found, try to build
    if [ -f "Cargo.toml" ]; then
        echo "Binaries not found. Attempting to build from source..."
        
        # Check if cargo is available
        if ! command -v cargo &> /dev/null; then
            echo "Error: cargo not found. Please install Rust or download prebuilt binaries."
            echo ""
            echo "To install Rust: https://rustup.rs/"
            echo "To download prebuilt binaries from: https://github.com/ZaviiNet/library-loader/releases"
            return 1
        fi
        
        echo "Building release binaries (this may take a few minutes)..."
        echo ""
        
        # Try to build everything
        if cargo build --release; then
            echo "✓ Build successful"
        else
            # If full build fails, try building just the CLI (GUI requires GTK3)
            echo ""
            echo "Full build failed (this is expected if GTK3 development libraries are not installed)."
            echo "Attempting to build CLI only..."
            echo ""
            if cargo build --release --bin library-loader-cli; then
                echo "✓ CLI build successful"
                echo ""
                echo "Note: GUI build was skipped due to missing GTK3 development libraries."
                echo "The CLI will be installed, but the GUI will not be available."
                echo ""
                echo "To build the GUI, install GTK3 development libraries:"
                echo "  - Debian/Ubuntu: sudo apt-get install libgtk-3-dev"
                echo "  - Fedora: sudo dnf install gtk3-devel"
                echo "  - Arch: sudo pacman -S gtk3"
            else
                echo "Error: Build failed"
                return 1
            fi
        fi
        
        # Check which binaries were successfully built
        if [ -f "target/release/library-loader-cli" ]; then
            CLI_BIN="target/release/library-loader-cli"
        fi
        
        if [ -f "target/release/library-loader-gui" ]; then
            GUI_BIN="target/release/library-loader-gui"
        fi
        
        if [ -z "${CLI_BIN}" ]; then
            echo "Error: CLI binary not found after build"
            return 1
        fi
        
        return 0
    else
        echo "Error: Unable to locate binaries"
        echo ""
        echo "Please either:"
        echo "  1. Build the project: cargo build --release"
        echo "  2. Download prebuilt binaries from: https://github.com/ZaviiNet/library-loader/releases"
        return 1
    fi
}

# Locate the binaries
if ! locate_binaries; then
    exit 1
fi

echo ""
echo "Installing binaries to ${BIN_DIR}..."

# Copy CLI binary (always required)
cp "${CLI_BIN}" "${BIN_DIR}/library-loader-cli"
chmod +x "${BIN_DIR}/library-loader-cli"
echo "✓ CLI installed"

# Copy GUI binary if available
if [ -n "${GUI_BIN}" ] && [ -f "${GUI_BIN}" ]; then
    cp "${GUI_BIN}" "${BIN_DIR}/library-loader-gui"
    chmod +x "${BIN_DIR}/library-loader-gui"
    echo "✓ GUI installed"
fi

# Install desktop file if it exists
DESKTOP_FILE=""
if [ -f "library-loader-gui.desktop" ]; then
    DESKTOP_FILE="library-loader-gui.desktop"
elif [ -f "ll-gui/library-loader-gui.desktop" ]; then
    DESKTOP_FILE="ll-gui/library-loader-gui.desktop"
fi

if [ -n "${DESKTOP_FILE}" ]; then
    echo "Installing desktop integration..."
    
    # Copy and update desktop file to use full path
    sed "s|Exec=library-loader-gui|Exec=${BIN_DIR}/library-loader-gui|g" \
        "${DESKTOP_FILE}" > "${APPLICATIONS_DIR}/library-loader-gui.desktop"
    
    chmod +x "${APPLICATIONS_DIR}/library-loader-gui.desktop"
    echo "✓ Desktop file installed"
fi

# Install icon if it exists
ICON_FILE=""
if [ -f "library-loader-icon.svg" ]; then
    ICON_FILE="library-loader-icon.svg"
elif [ -f "ll-gui/assets/library-loader-icon.svg" ]; then
    ICON_FILE="ll-gui/assets/library-loader-icon.svg"
fi

if [ -n "${ICON_FILE}" ]; then
    cp "${ICON_FILE}" "${ICONS_DIR}/net.olback.LibraryLoader.svg"
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
if [ -n "${GUI_BIN}" ] && [ -f "${BIN_DIR}/library-loader-gui" ]; then
    echo "  - library-loader-gui"
fi
echo ""
