# Library Loader :books:

<!-- ![Screenshot](libloader.png) -->

<!-- Status: [![CircleCI](https://circleci.com/gh/olback/library-loader/tree/master.svg?style=svg)](https://circleci.com/gh/olback/library-loader/tree/master) -->

Status: [![Build Status](https://drone.olback.dev/api/badges/olback/library-loader/status.svg)](https://drone.olback.dev/olback/library-loader)

<!---
OS | Status
-- | ------
Linux | [![CircleCI](https://circleci.com/gh/olback/library-loader/tree/master.svg?style=svg)](https://circleci.com/gh/olback/library-loader/tree/master)
Windows | WIP
Mac | WIP
--->

## What is Library Loader?

Library Loader is a cross-platform Rust application that automatically downloads and organizes electronic component libraries from [Component Search Engine](https://componentsearchengine.com/) for use in various ECAD tools like KiCad, EAGLE, EasyEDA, and more.

### Key Features

- 🔄 **Automatic Library Processing**: Monitors a directory and automatically processes component libraries
- 🎨 **Multiple Format Support**: KiCad, EAGLE, EasyEDA, DesignSpark PCB, and more
- 🖥️ **Dual Interface**: Command-line (CLI) and graphical (GUI) interfaces
- 📦 **Bazzite/Silverblue Support**: User-local installation for immutable Linux distributions
- ✨ **KiCad QoL Improvements**: 
  - Separate folder for `*.kicad_mod` files
  - Concatenated legacy `*.lib` and `*.dcm` files
  - Automatic filtering of obsolete `*.mod` files

## Getting Started

### Prerequisites

1. Create an account on [componentsearchengine.com](https://componentsearchengine.com/) if you don't have one already.
2. Download a prebuilt version of library-loader from the [releases page](https://github.com/olback/library-loader/releases) (currently Linux builds only).

### Installation

**Which Installation Method Should I Use?**

- **Standard Linux (Ubuntu, Debian, Arch, etc.)**: Use `dist-install.sh` for system-wide installation
- **Bazzite/Silverblue/Atomic (CLI only or with pre-built binaries)**: Use `user-install.sh`
- **Bazzite/Silverblue/Atomic (with GUI from source)**: Use `distrobox-install.sh` to avoid rpm-ostree conflicts
- **No root access**: Use `user-install.sh` or `distrobox-install.sh`

#### Standard Linux (System-Wide)

For traditional Linux distributions with writable system directories:

```sh
# Extract the archive
tar -xzf library-loader-linux-dist.tar.gz
cd library-loader-linux-dist

# Install system-wide (requires sudo)
sudo ./dist-install.sh
```

This installs binaries to `/usr/bin/`, desktop files to `/usr/share/applications/`, and icons to `/usr/share/icons/`.

#### Bazzite/Silverblue/Read-Only Filesystems (User-Local)

For immutable Linux distributions or when you don't have root access:

```sh
# Extract the archive
tar -xzf library-loader-linux-dist.tar.gz
cd library-loader-linux-dist

# Install to user directory (no sudo required)
./user-install.sh
```

This installs everything to `~/.local/` directories. **Make sure `~/.local/bin` is in your PATH**:

```sh
export PATH="${HOME}/.local/bin:${PATH}"
```

Add this line to your `~/.bashrc` or `~/.zshrc` to make it permanent.

**Note:** The user-local installation may skip the GUI if GTK3 development libraries are not available. For full GUI support on immutable systems, see the Distrobox installation method below.

#### Bazzite/Silverblue with GUI Support (Distrobox)

For immutable Linux distributions where installing GTK3 development libraries causes conflicts, you can build in a container with distrobox:

```sh
# Clone or extract the source code
git clone https://github.com/ZaviiNet/library-loader.git
cd library-loader

# Build and install using distrobox (includes GUI)
./distrobox-install.sh
```

This method:
- Creates a Fedora container with GTK3 development libraries
- Builds both CLI and GUI inside the container
- Installs binaries to `~/.local/bin` on your host system
- Works around rpm-ostree dependency conflicts on atomic systems

The distrobox container is kept for future rebuilds and can be removed later with `distrobox rm library-loader-build`.

#### Uninstallation

```sh
# System-wide uninstall
sudo ./dist-uninstall.sh

# User-local uninstall
./user-uninstall.sh

# Distrobox uninstall (also offers to remove container)
./distrobox-uninstall.sh
```

### Quick Start

1. **Generate Configuration**:
   ```sh
   library-loader-cli --generate
   ```
   
2. **Edit Configuration**: Open `LibraryLoader.toml` and add your credentials
   
3. **Start Watching**:
   ```sh
   library-loader-cli
   ```
   
4. **Download Libraries**: Go to componentsearchengine.com, find a component, and download the library file to your watch path (default: `~/Downloads`)

For detailed usage instructions, see [USAGE.md](USAGE.md).

### Building from Source

#### Using Docker

Build without installing dependencies on your machine:

```sh
docker run --volume=$(pwd):/home/circleci/project olback/rust-gtk-linux cargo build --release
```

#### Building Locally (macOS)

Required: brew (from Homebrew), rustc, cargo

```shell
./macos-compile.sh
```

### Setup on macOS

Edit `LibraryLoader.example.toml` with your componentsearchengine.com credentials, then:

```shell
cp LibraryLoader.example.toml ~/Library/Application\ Support/LibraryLoader.toml
```

### Running on macOS

GUI:
```shell
cargo run --bin library-loader-gui
```

CLI:
```shell
cargo run --bin library-loader-cli
```

## Documentation

- **[USAGE.md](USAGE.md)** - Comprehensive user guide
- **[CHANGELOG.md](CHANGELOG.md)** - Version history
- **[TODO.md](TODO.md)** - Upcoming features

## What/Why?

This is a Rust implementation of [SamacSys Library Loader](https://www.samacsys.com/library-loader/). Since the official library-loader only works on Windows, this project provides a cross-platform alternative available to everyone.

## Recent Improvements

### v0.4.0+ Enhancements

- **Bazzite/Silverblue Support**: New user-local installation scripts for immutable Linux distributions
- **KiCad QoL Improvements**:
  - `*.kicad_mod` files copied to separate `{LibraryName}_footprints/` folder for easier management
  - Legacy `*.lib` files concatenated into single library file
  - Legacy `*.dcm` files concatenated into single documentation file  
  - Obsolete `*.mod` files automatically filtered out
- **Enhanced Documentation**: Comprehensive USAGE.md with examples and troubleshooting
- **Improved Installation**: Better error messages and guidance for different installation methods

## License

[GNU Affero General Public License v3.0](LICENSE)
