#!/bin/bash

set -e

# Distrobox installation script for Library Loader
# This script builds the application (including GUI) in a Fedora container with GTK3 
# development libraries, then installs to ~/.local/bin for use on the host system.
#
# This is ideal for immutable Linux distributions (Bazzite, Silverblue, Kinoite, etc.)
# where installing GTK3 development libraries causes dependency conflicts.

echo "Library Loader - Distrobox Installation"
echo "=========================================="
echo ""
echo "This script will:"
echo "  1. Create a Fedora distrobox container (if not exists)"
echo "  2. Build Library Loader with full GUI support inside the container"
echo "  3. Install binaries to ~/.local/bin on your host system"
echo ""

# Determine installation directories on host
BIN_DIR="${HOME}/.local/bin"
SHARE_DIR="${HOME}/.local/share"
APPLICATIONS_DIR="${SHARE_DIR}/applications"
ICONS_DIR="${SHARE_DIR}/icons/hicolor/scalable/apps"

# Check if distrobox is installed
if ! command -v distrobox &> /dev/null; then
    echo "Error: distrobox is not installed"
    echo ""
    echo "On Bazzite/Silverblue, distrobox should be pre-installed."
    echo "If not, install it with:"
    echo "  rpm-ostree install distrobox"
    echo ""
    echo "For other distributions, see: https://distrobox.it"
    exit 1
fi

# Check if we're in the source directory
if [ ! -f "Cargo.toml" ]; then
    echo "Error: This script must be run from the library-loader source directory"
    echo "Expected to find Cargo.toml in current directory"
    exit 1
fi

# Container and image configuration
CONTAINER_NAME="library-loader-build"
CONTAINER_IMAGE="fedora:latest"

# Check if container already exists
if distrobox list | grep -q "${CONTAINER_NAME}"; then
    echo "✓ Found existing distrobox container: ${CONTAINER_NAME}"
else
    echo "Creating distrobox container: ${CONTAINER_NAME}"
    echo "This may take a few minutes on first run..."
    echo ""
    
    if ! distrobox create --name "${CONTAINER_NAME}" --image "${CONTAINER_IMAGE}"; then
        echo "Error: Failed to create distrobox container"
        exit 1
    fi
    
    echo "✓ Container created"
fi

echo ""
echo "Installing dependencies in container..."
echo ""

# Install build dependencies in container
distrobox enter "${CONTAINER_NAME}" -- bash -c '
    set -e
    
    # Update package cache
    sudo dnf check-update || true
    
    # Install Rust if not present
    if ! command -v cargo &> /dev/null; then
        echo "Installing Rust..."
        curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "${HOME}/.cargo/env"
    fi
    
    # Install GTK3 development libraries and other dependencies
    echo "Installing GTK3 and build dependencies..."
    sudo dnf install -y gtk3-devel gcc pkg-config
    
    echo "✓ Dependencies installed"
'

if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies in container"
    exit 1
fi

echo ""
echo "Building Library Loader (with GUI) in container..."
echo "This may take several minutes..."
echo ""

# Build the project in container
# Use the current directory mounted in distrobox
CURRENT_DIR="$(pwd)"
distrobox enter "${CONTAINER_NAME}" -- bash -c "
    set -e
    
    # Source Rust environment
    if [ -f \"\${HOME}/.cargo/env\" ]; then
        source \"\${HOME}/.cargo/env\"
    fi
    
    # Navigate to project directory (distrobox automatically mounts home)
    cd \"${CURRENT_DIR}\"
    
    # Build release binaries
    cargo build --release
    
    echo \"\"
    echo \"✓ Build successful\"
"

if [ $? -ne 0 ]; then
    echo "Error: Build failed"
    exit 1
fi

echo ""
echo "Installing binaries to ${BIN_DIR}..."
echo ""

# Create directories if they don't exist
mkdir -p "${BIN_DIR}"
mkdir -p "${APPLICATIONS_DIR}"
mkdir -p "${ICONS_DIR}"

# Copy binaries from build output
if [ ! -f "target/release/library-loader-cli" ]; then
    echo "Error: CLI binary not found after build"
    exit 1
fi

cp "target/release/library-loader-cli" "${BIN_DIR}/library-loader-cli"
chmod +x "${BIN_DIR}/library-loader-cli"
echo "✓ CLI installed"

if [ -f "target/release/library-loader-gui" ]; then
    cp "target/release/library-loader-gui" "${BIN_DIR}/library-loader-gui"
    chmod +x "${BIN_DIR}/library-loader-gui"
    echo "✓ GUI installed"
else
    echo "⚠ Warning: GUI binary not found"
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
echo "The distrobox container '${CONTAINER_NAME}' has been kept for future rebuilds."
echo "To remove it later, run: distrobox rm ${CONTAINER_NAME}"
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
if [ -f "${BIN_DIR}/library-loader-gui" ]; then
    echo "  - library-loader-gui"
fi
echo ""
