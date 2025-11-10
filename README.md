# Starch (Start Arch) - Arch post-install script.

A comprehensive automated setup script for Arch Linux that transforms a minimal installation into a fully-featured Hyprland-based desktop environment with all essential applications and configurations.
<img width="1920" height="1080" alt="starch-screenshot-4" src="https://github.com/user-attachments/assets/270038f4-4505-40fa-a4f0-6f3bfbfa3239" />
<img width="1920" height="1080" alt="starch-screenshot-3" src="https://github.com/user-attachments/assets/8bc71faf-6371-4802-89c1-8f50f36e3553" />
<img width="1920" height="1080" alt="starch-screenshot-2" src="https://github.com/user-attachments/assets/6e3ea729-edc5-4ccf-876a-b5413a729d69" />
<img width="1920" height="1080" alt="starch-screenshot-1" src="https://github.com/user-attachments/assets/d47bfcfa-2a6b-4ddf-8564-c86f1b567b53" />
## Overview

This script is designed to be run **immediately after a minimal Arch Linux installation**. It automates the entire post-installation process, including:

- Installing and configuring an AUR helper (paru)
- Setting up the Hyprland Wayland compositor with all necessary components
- Installing essential system utilities and applications
- Configuring GPU drivers (AMD/NVIDIA/Intel)
- Setting up system services (printing, audio, Bluetooth, networking, etc.)
- Copying pre-configured dotfiles
- Optimizing package mirrors for your location

## Prerequisites

- A **minimal Arch Linux installation** with:
  - Base system installed
  - Bootloader configured
  - Network connection working
  - A regular user account (non-root) with sudo privileges
- Internet connection
- Git installed (`sudo pacman -S git`)

## What Gets Installed

### Desktop Environment
- **Hyprland** - Wayland compositor
- **ly** - Display manager
- **Waybar** - Status bar
- **wofi** - Application launcher
- **swaync** - Notification daemon
- **kitty** - Terminal emulator

### Hyprland Utilities
- **hyprpaper** - Wallpaper manager
- **hypridle** - Idle daemon
- **hyprlock** - Screen locker
- **hyprsunset** - Blue light filter
- **hyprshot** - Screenshot tool
- **hyprpolkitagent** - Authentication agent

### Audio & Media
- **PipeWire** - Audio server (with PulseAudio compatibility)
- **WirePlumber** - Session manager
- **mpv** - Media player
- **imv** - Image viewer
- **pwvucontrol** - PipeWire volume control

### System Utilities
- **NetworkManager** - Network management
- **Bluetooth** (bluez, blueman) - Bluetooth support
- **CUPS** - Printing support
- **udiskie** - Automatic USB mounting
- **brightnessctl** - Brightness control
- **power-profiles-daemon** - Power management
- **firewalld** - Firewall

### File Management
- **thunar** - GUI file manager
- **yazi** - Terminal file manager
- **gvfs** - Virtual filesystem (MTP, network shares, etc.)
- Support for NTFS, exFAT, and other filesystems

### Development & CLI Tools
- **helix** - Modern terminal text editor
- **tmux** - Terminal multiplexer
- **starship** - Shell prompt
- **zoxide** - Smart directory navigation
- **fzf** - Fuzzy finder
- **ripgrep** - Fast grep alternative
- **bat** - Cat with syntax highlighting
- **fd** - User-friendly find alternative
- **btop** - System monitor
- **fastfetch** - System information

### Applications (Flatpak)
- Discord
- Bitwarden
- Flatseal
- Faugus Launcher
- PDF Arranger
- Pinta (image editor)
- LocalSend
- OnlyOffice
- Warehouse (Flatpak manager)

### Additional Software
- **OpenTabletDriver** - Graphics tablet support
- **Gamescope** - Gaming compositor
- **nwg-look** - GTK theme manager
- **Xournalpp** - Note-taking
- **Okular** - Document viewer
- **GNOME Disk Utility**
- **JDK 21** - Java development kit
- Various fonts including Nerd Fonts

### GPU Drivers
The script will interactively ask which GPU you have and install appropriate drivers:
- **AMD**: mesa, vulkan-radeon, hardware acceleration
- **NVIDIA**: proprietary drivers with Wayland support
- **Intel**: mesa, vulkan-intel, media drivers

All GPU drivers include 32-bit libraries for gaming compatibility.

## Directory Structure

```
Arch-Setup/
├── setup.sh              # Main installation script
└── configs/              # Configuration files directory
    ├── backgrounds/      # Wallpapers
    ├── btop/            # System monitor config
    ├── fastfetch/       # System info config
    ├── helix/           # Text editor config
    ├── hypr/            # Hyprland configs
    ├── kitty/           # Terminal config
    ├── waybar/          # Status bar config
    ├── wofi/            # Launcher config
    ├── yazi/            # File manager config
    └── starship.toml    # Shell prompt config
```

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/arch-setup.git
cd arch-setup
```

### 2. Make the Script Executable

```bash
chmod +x setup.sh
```

### 3. Run the Script

```bash
./setup.sh
```

### 4. Follow the Prompts

The script will ask you:
1. Whether to delete the Arch-Setup directory after completion
2. Which GPU type you have (AMD/NVIDIA/Intel/None)

### 5. Reboot

After the script completes successfully, reboot your system:

```bash
sudo reboot
```

## What the Script Does

1. **Updates system packages** - Ensures your system is up to date
2. **Installs reflector** - Tool for optimizing package mirrors
3. **Optimizes mirrors** - Automatically finds the fastest mirrors near you
4. **Installs paru** - AUR helper for accessing community packages
5. **Installs all packages** - System packages, utilities, and applications
6. **Installs GPU drivers** - Based on your hardware selection
7. **Generates XDG directories** - Creates standard user directories (Documents, Downloads, etc.)
8. **Sets up Flatpak** - Adds Flathub repository and installs Flatpak apps
9. **Creates .bashrc** - Sets up shell configuration with aliases and tools
10. **Copies dotfiles** - Copies all configuration files to appropriate locations
11. **Enables system services** - Activates necessary systemd services
12. **Sets file permissions** - Ensures proper security on config files
13. **Cleans up** - Optionally removes the setup directory

## Enabled System Services

After installation, the following services will be enabled and running:

- **ly.service** - Display manager (auto-login screen)
- **NetworkManager.service** - Network connectivity
- **bluetooth.service** - Bluetooth support
- **cups.service** - Printing service
- **firewalld.service** - Firewall
- **power-profiles-daemon.service** - Power management
- **pipewire.service** - Audio server
- **udiskie.service** - USB automounting
- **paccache.timer** - Automatic package cache cleanup

## Bash Aliases

The script configures the following aliases in your `.bashrc`:

- `hx` - Shortcut for helix editor
- `i` - Install packages (`paru -S`)
- `u` - Update system (`paru -Syu`)
- `r` - Remove packages (`paru -Rns`)
- `sr` - Search for packages (`paru -Ss`)
- `ss` - Search installed packages (`paru -Q | rg`)
- `news` - Show Arch news (`paru -Pww`)

## Post-Installation

After rebooting, you'll be greeted by the **ly** display manager. Log in to your Hyprland session.

### Manual Configuration

Some applications may require additional setup:

- **Hyprland**: Review and customize `~/.config/hypr/hyprland.conf`
- **OpenTabletDriver**: Configure via GUI if you use a graphics tablet
- **Printers**: Add printers via `system-config-printer`
- **Bluetooth**: Pair devices via `blueman-manager`
- **Firewall**: Configure rules if needed

### Useful Commands

- Check audio status: `wpctl status`
- Control volume: Use `pwvucontrol` or `wpctl set-volume @DEFAULT_SINK@ 5%+`
- Manage printers: `system-config-printer`
- Manage Bluetooth: `blueman-manager`
- Update mirrors: `sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist`

## Customization

All configuration files are located in `~/.config/`. Feel free to customize:

- **Hyprland**: Window manager behavior and keybindings
- **Waybar**: Status bar appearance and modules
- **Kitty**: Terminal colors and font settings
- **Starship**: Shell prompt design
- **Wofi**: Launcher appearance

## Troubleshooting

### Script Fails During Package Installation

- Check your internet connection
- Try running the script again (it will skip already-installed packages)
- Manually install the failing package to see detailed error messages

### NVIDIA Users

If you experience issues with Hyprland on NVIDIA:
- Ensure you have the latest NVIDIA drivers
- Check that DRM kernel mode setting is enabled
- You may need to add kernel parameters to your bootloader

### Display Manager Won't Start

- Check ly service status: `sudo systemctl status ly.service`
- View logs: `sudo journalctl -u ly.service`
- Try restarting the service: `sudo systemctl restart ly.service`


**Note**: This script makes significant changes to your system. While it includes error handling, it's recommended to review the script before running it and ensure you have backups of any important data. Shift + Super + H brings up the keybindings list.
