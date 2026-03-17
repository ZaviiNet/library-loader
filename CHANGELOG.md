# 0.5.0 (Unreleased)
* **Distrobox Support**: Added `distrobox-install.sh` and `distrobox-uninstall.sh` for building with full GUI support on immutable Linux systems (Bazzite, Silverblue) by using a Fedora container. Solves rpm-ostree GTK3 dependency conflicts.
* **Bazzite/Silverblue Support**: Added user-local installation scripts (`user-install.sh` and `user-uninstall.sh`) for immutable/read-only filesystems
* **KiCad QoL Improvements**:
  * `*.kicad_mod` files now copied to both `.pretty/` and separate `{LibraryName}_footprints/` folder for easier management
  * Legacy `*.lib` files concatenated into single library file
  * Legacy `*.dcm` files concatenated into single documentation file
  * Obsolete `*.mod` files (legacy footprints) automatically filtered out
* **Documentation**: Added comprehensive USAGE.md with installation instructions, configuration examples, and troubleshooting. Added distrobox installation method and troubleshooting for rpm-ostree conflicts.
* **Code Quality**: Fixed clippy warnings and improved code patterns
* **Installation**: Updated `dist-install.sh` with better error messages and guidance for Bazzite users

# 0.4.0
* Bump dependencies.


## 0.3.1
* Added DesignSpark (#75)

## 0.3.0
* Refactored
* Supports multiple formats (#15, #17, #62)
* New Config format (incompatible, remove/rename old config)
* Reworked UI
* Fewer CLI options
* Now ignores non ZIP files (#17, #53)
* Uses Rustls instead of OpenSSL

## 0.2.2
* Update download url (fixes 401 errors)

## 0.2.1
* Updated 'Update Instructions'
* Added Docker build instructions(thanks @4c0n)
* Fixed typo (thanks @4c0n)
* Hopefully fixed automatic releases
* Fix version missmatch in `ll-core`

## 0.2.0
* Added GUI version
* Major refactor

## 0.1.2
* Automatic update checks
* No longer creates a folder for downloaded library unless the format specifies it
* No longer overwrites output files
* Code refactoring
