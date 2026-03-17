# Library Loader - User Guide

Library Loader is a cross-platform application that automatically downloads and organizes electronic component libraries from Component Search Engine (CSE) for use in various ECAD tools like KiCad, EAGLE, and more.

## Table of Contents

1. [Installation](#installation)
2. [Configuration](#configuration)
3. [Basic Usage](#basic-usage)
4. [KiCad Integration](#kicad-integration)
5. [Bazzite/Silverblue Support](#bazzitesilverblue-support)
6. [Troubleshooting](#troubleshooting)

## Installation

### Standard Linux Installation (System-Wide)

For traditional Linux distributions with writable system directories:

```bash
# Extract the distribution archive
tar -xzf library-loader-linux-dist.tar.gz
cd library-loader-linux-dist

# Install system-wide (requires sudo)
sudo ./dist-install.sh
```

This will install:
- Binaries to `/usr/bin/`
- Desktop file to `/usr/share/applications/`
- Icon to `/usr/share/icons/`

### User-Local Installation (Bazzite/Silverblue/Read-Only Filesystems)

For immutable/read-only Linux distributions like Bazzite, Silverblue, or when you don't have root access:

```bash
# Extract the distribution archive
tar -xzf library-loader-linux-dist.tar.gz
cd library-loader-linux-dist

# Install to user directory (no sudo required)
./user-install.sh
```

This will install:
- Binaries to `~/.local/bin/`
- Desktop file to `~/.local/share/applications/`
- Icon to `~/.local/share/icons/`

**Important:** Make sure `~/.local/bin` is in your PATH. Add this to your `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="${HOME}/.local/bin:${PATH}"
```

Then restart your terminal or run: `source ~/.bashrc`

### Verification

After installation, verify by running:

```bash
library-loader-cli --help
```

Or launch the GUI from your application menu or by running:

```bash
library-loader-gui
```

## Configuration

Library Loader uses a TOML configuration file to store settings, credentials, and output format preferences.

### Configuration File Location

- **CLI Default:** `./LibraryLoader.toml` (current directory)
- **CLI Global:** `~/.config/LibraryLoader.toml` (use `--global-config` flag)
- **GUI:** Always uses `~/.config/LibraryLoader.toml`

### Creating a Configuration File

#### Using CLI

```bash
# Generate config in current directory
library-loader-cli --generate

# Generate global config
library-loader-cli --global-config --generate

# Overwrite existing config
library-loader-cli --generate --overwrite
```

#### Using GUI

1. Launch `library-loader-gui`
2. Fill in your Component Search Engine credentials
3. Configure watch path and output formats
4. Settings are automatically saved to `~/.config/LibraryLoader.toml`

### Configuration File Format

```toml
[settings]
# Directory to watch for downloaded .epw/.zip files
watch_path = "~/Downloads"
# Watch subdirectories (true/false)
recursive = false

# KiCad format configuration
[formats.'kicad']
format = "kicad"
output_path = "~/.local/share/kicad/8.0/3rdparty/symbols"

# EAGLE format configuration (optional)
[formats.'eagle']
format = "eagle"
output_path = "~/EAGLE/libraries"

# 3D models format (optional)
[formats.'3d']
format = "3d"
output_path = "~/3d_models"

# Component Search Engine credentials
[profile]
username = "your-email@example.com"
password = "your-password"
```

### Supported Formats

- `kicad` - KiCad libraries (symbols, footprints, 3D models)
- `eagle` - EAGLE libraries
- `easyeda` - EasyEDA libraries
- `designspark` - DesignSpark PCB libraries
- `3d` - 3D models only
- `zip` - Raw ZIP archives (no processing)

## Basic Usage

### CLI Usage

Once configured, start the file watcher:

```bash
# Use config in current directory
library-loader-cli

# Use global config
library-loader-cli --global-config

# Use custom config file
library-loader-cli --config /path/to/config.toml

# Override watch path
library-loader-cli --watch ~/custom/path
```

The CLI will:
1. Monitor the configured watch path
2. Detect `.epw` or `.zip` files
3. Automatically download and extract libraries
4. Process files according to configured formats
5. Place libraries in the configured output paths

Press **Enter** to stop the watcher.

### GUI Usage

1. Launch `library-loader-gui` from your application menu or terminal
2. Enter your Component Search Engine credentials
3. Configure the watch path (default: `~/Downloads`)
4. Add output formats:
   - Click "+" to add a new format
   - Select format type (KiCad, EAGLE, etc.)
   - Choose output directory
   - Give it a name
5. Click "Start Watching" to begin monitoring
6. View processing logs in the bottom panel

### Workflow

1. **Log in to Component Search Engine** (https://componentsearchengine.com)
2. **Search for a component** (e.g., "ATMEGA328P-AU")
3. **Download the component library**:
   - Click "Download" button
   - Save the `.epw` or `.zip` file to your watch path (e.g., `~/Downloads`)
4. **Automatic Processing**:
   - Library Loader detects the file
   - Downloads the full library from CSE
   - Extracts and processes files
   - Organizes libraries in your output directories
5. **Use in your ECAD tool**:
   - Open KiCad/EAGLE/etc.
   - Your new libraries are ready to use!

## KiCad Integration

### KiCad Output Structure

Library Loader creates the following structure for KiCad libraries:

```
output_path/
├── {LibraryName}.kicad_sym          # Symbol library (modern format)
├── {LibraryName}.pretty/            # Footprint library folder
│   ├── footprint1.kicad_mod
│   ├── footprint2.kicad_mod
│   └── model.wrl                    # 3D models
├── {LibraryName}_footprints/        # Separate footprints folder (QoL)
│   ├── footprint1.kicad_mod
│   └── footprint2.kicad_mod
├── {LibraryName}.lib                # Legacy symbol library (if present)
└── {LibraryName}.dcm                # Legacy symbol metadata (if present)
```

### KiCad QoL Improvements

Recent updates include several quality-of-life improvements for KiCad users:

1. **Separate Footprint Folder**: `*.kicad_mod` files are copied to both:
   - `{LibraryName}.pretty/` (standard KiCad location)
   - `{LibraryName}_footprints/` (dedicated folder for easier management)

2. **Legacy File Concatenation**: Multiple legacy files are concatenated:
   - All `*.lib` files → Single `{LibraryName}.lib`
   - All `*.dcm` files → Single `{LibraryName}.dcm`

3. **Obsolete File Filtering**: `*.mod` files (obsolete legacy footprints) are automatically skipped

### Adding Libraries to KiCad

#### Symbols

1. Open KiCad
2. Go to **Preferences → Manage Symbol Libraries**
3. Click **+** to add a new library
4. Browse to your `output_path` and select `{LibraryName}.kicad_sym`
5. Choose "Global Libraries" or "Project Specific Libraries"
6. Click **OK**

#### Footprints

1. Open KiCad
2. Go to **Preferences → Manage Footprint Libraries**
3. Click **+** to add a new library
4. Browse to your `output_path` and select `{LibraryName}.pretty` folder
5. Choose "Global Libraries" or "Project Specific Libraries"
6. Click **OK**

### Recommended KiCad Output Path

For **KiCad 8.x** (and later):
```toml
[formats.'kicad']
format = "kicad"
output_path = "~/.local/share/kicad/8.0/3rdparty"
```

For **KiCad 7.x**:
```toml
[formats.'kicad']
format = "kicad"
output_path = "~/.local/share/kicad/7.0/3rdparty"
```

## Bazzite/Silverblue Support

### What is Bazzite?

Bazzite is an immutable Linux distribution based on Fedora Silverblue, designed for gaming and creative work. It uses a read-only root filesystem for stability and security.

### Why Special Support?

Traditional Linux applications install to system directories like `/usr/bin`, which are read-only on Bazzite. Library Loader now supports user-local installation, placing all files in `~/.local/`, which is always writable.

### Installation on Bazzite

```bash
# Download and extract
tar -xzf library-loader-linux-dist.tar.gz
cd library-loader-linux-dist

# Install to user directory (no sudo needed)
./user-install.sh
```

### Path Configuration

Ensure `~/.local/bin` is in your PATH:

```bash
# Check if it's already there
echo $PATH | grep ".local/bin"

# If not, add to ~/.bashrc
echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> ~/.bashrc
source ~/.bashrc
```

### Uninstallation

```bash
# Navigate to the extracted directory
cd library-loader-linux-dist

# Run user uninstall script
./user-uninstall.sh
```

This removes:
- Binaries from `~/.local/bin/`
- Desktop file from `~/.local/share/applications/`
- Icon from `~/.local/share/icons/`

**Note:** Your configuration file (`~/.config/LibraryLoader.toml`) and downloaded libraries are preserved.

### Configuration on Bazzite

Since your home directory is writable, you can use standard paths:

```toml
[settings]
watch_path = "~/Downloads"

[formats.'kicad']
format = "kicad"
output_path = "~/.local/share/kicad/8.0/3rdparty"
```

## Troubleshooting

### "Must run as root" Error

**Symptom:** Running `./dist-install.sh` shows "Must run as root" error.

**Solution:** 
- On Bazzite/Silverblue: Use `./user-install.sh` instead (no sudo required)
- On standard Linux: Run with `sudo ./dist-install.sh`

### "library-loader-cli: command not found"

**Symptom:** After installation, running `library-loader-cli` fails.

**Solutions:**
1. Ensure `~/.local/bin` is in your PATH (user-local install)
2. Restart your terminal
3. Run `source ~/.bashrc` or `source ~/.zshrc`
4. Check installation: `ls ~/.local/bin/library-loader-*`

### Libraries Not Appearing in KiCad

**Symptom:** Downloaded libraries don't show up in KiCad.

**Solutions:**
1. Verify output path in config matches where you're looking
2. Manually add libraries in KiCad preferences
3. Check file permissions: `ls -la ~/output/path/`
4. Ensure Library Loader completed processing (check logs)

### Authentication Failed

**Symptom:** "Authentication failed" or "Invalid credentials" error.

**Solutions:**
1. Verify credentials at https://componentsearchengine.com
2. Check for typos in config file
3. Ensure no extra spaces in username/password
4. Update password if changed on CSE website
5. Regenerate config with `--generate --overwrite`

### File Not Detected

**Symptom:** Downloaded files aren't being processed.

**Solutions:**
1. Verify watch_path in config is correct
2. Ensure files have `.epw` or `.zip` extension
3. Check file permissions
4. Try moving file after watcher is running
5. Enable recursive watching if files are in subdirectories

### GUI Not Starting

**Symptom:** `library-loader-gui` fails to launch.

**Solutions:**
1. Check if GTK3 is installed: `gtk-launch --version`
2. Run from terminal to see error messages: `library-loader-gui`
3. Verify desktop file is installed: `ls ~/.local/share/applications/library-loader-gui.desktop`
4. Update icon cache: `gtk-update-icon-cache ~/.local/share/icons/hicolor`

### Permission Denied Errors

**Symptom:** "Permission denied" when creating files.

**Solutions:**
1. Check output path permissions: `ls -ld ~/output/path`
2. Create directory manually: `mkdir -p ~/output/path`
3. Verify ownership: `ls -l ~/output/path`
4. Use paths in your home directory (avoid system directories)

## Tips and Best Practices

### 1. Use Consistent Output Paths

Keep all your libraries organized in one location:

```toml
[formats.'kicad']
output_path = "~/.local/share/kicad/8.0/3rdparty"
```

### 2. Enable Multiple Formats

If you use multiple tools, configure them all:

```toml
[formats.'kicad']
format = "kicad"
output_path = "~/.local/share/kicad/8.0/3rdparty"

[formats.'eagle']
format = "eagle"
output_path = "~/EAGLE/libraries"
```

### 3. Clean Up Watch Path

Periodically remove processed files from your watch path (Downloads folder) to keep it organized.

### 4. Backup Configuration

Save a copy of your config file:

```bash
cp ~/.config/LibraryLoader.toml ~/.config/LibraryLoader.toml.backup
```

### 5. Use GUI for Initial Setup

The GUI makes it easier to configure settings interactively, then use the CLI for automated workflows.

### 6. Test with Sample Component

Try a simple component first (e.g., a resistor or capacitor) to verify everything works before downloading large libraries.

## Support

- **Issues:** https://github.com/ZaviiNet/library-loader/issues
- **Original Project:** https://github.com/olback/library-loader
- **Component Search Engine:** https://componentsearchengine.com

## Version

This documentation is for Library Loader v0.4.0+

Last Updated: March 2026
