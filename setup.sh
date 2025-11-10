#!/bin/bash

# Arch Linux Post-Install Setup Script
# This script installs packages, configures system services, and copies config files

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_question() {
    echo -e "${BLUE}[QUESTION]${NC} $1"
}

# Error handler function
error_handler() {
    local line_number=$1
    print_error "Script failed at line $line_number"
    print_error "Setup incomplete. Please check the error above and try again."
    exit 1
}

# Set up error trap
trap 'error_handler ${LINENO}' ERR

# Check if script is run as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root. It will ask for sudo when needed."
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/configs"

# Welcome message
echo ""
echo "=========================================="
echo "  Arch Linux Post-Install Setup Script"
echo "=========================================="
echo ""
print_message "Script directory: $SCRIPT_DIR"
echo ""

# Verify required directories exist
if [ ! -d "$CONFIG_DIR" ]; then
    print_error "configs directory not found at $CONFIG_DIR"
    exit 1
fi

# Ask if user wants to delete the setup directory after completion
DELETE_AFTER_SETUP=false
print_question "Do you want to delete the Starch directory after setup completes? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    DELETE_AFTER_SETUP=true
    print_warning "The Starch directory will be deleted after successful completion."
else
    print_message "The Starch directory will be kept after setup."
fi
echo ""

# Ask about GPU type for driver installation
print_question "Which GPU do you have?"
echo "1) AMD"
echo "2) NVIDIA"
echo "3) Intel"
echo "4) VM/Other (skip GPU drivers)"
read -p "Enter choice [1-4]: " gpu_choice
echo ""

case $gpu_choice in
    1)
        GPU_TYPE="amd"
        print_message "AMD GPU selected - will install mesa and vulkan-radeon drivers"
        ;;
    2)
        GPU_TYPE="nvidia"
        print_message "NVIDIA GPU selected - will install proprietary NVIDIA drivers"
        ;;
    3)
        GPU_TYPE="intel"
        print_message "Intel GPU selected - will install mesa and vulkan-intel drivers"
        ;;
    4)
        GPU_TYPE="none"
        print_message "Skipping GPU driver installation"
        ;;
    *)
        print_warning "Invalid choice, skipping GPU driver installation"
        GPU_TYPE="none"
        ;;
esac
echo ""

print_message "Starting Arch Linux post-install setup..."

# Update system
print_message "Updating system packages..."
if ! sudo pacman -Syu --noconfirm; then
    print_error "Failed to update system packages."
    exit 1
fi

# Install base-devel if not already installed (required for AUR)
print_message "Installing base-devel, git, rust, and build tools..."
if ! sudo pacman -S --needed --noconfirm base-devel git reflector rust cargo; then
    print_error "Failed to install base-devel, git, reflector, rust, and cargo."
    exit 1
fi

# Update mirror list with reflector
print_message "Updating mirror list with reflector (detecting fastest mirrors)..."
if sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist; then
    print_message "Mirror list updated successfully with the fastest available mirrors!"
else
    print_warning "Failed to update mirror list, but continuing..."
fi

# Install paru (AUR helper)
print_message "Installing paru..."
if ! command -v paru &> /dev/null; then
    # Install paru-bin (pre-compiled binary) to avoid rust compilation issues
    cd /tmp
    # Remove existing paru-bin directory if it exists
    if [ -d "paru-bin" ]; then
        print_message "Removing existing paru-bin directory..."
        rm -rf paru-bin
    fi
    
    if ! git clone https://aur.archlinux.org/paru-bin.git; then
        print_error "Failed to clone paru-bin repository."
        exit 1
    fi
    cd paru-bin
    if ! makepkg -si --noconfirm; then
        print_error "Failed to install paru-bin."
        print_error "Trying alternative method with yay..."
        
        # Fallback to yay if paru fails
        cd /tmp
        if [ -d "yay-bin" ]; then
            rm -rf yay-bin
        fi
        
        if ! git clone https://aur.archlinux.org/yay-bin.git; then
            print_error "Failed to clone yay-bin repository."
            exit 1
        fi
        cd yay-bin
        if ! makepkg -si --noconfirm; then
            print_error "Failed to install yay-bin as fallback."
            exit 1
        fi
        # Create paru alias to yay
        sudo ln -sf /usr/bin/yay /usr/bin/paru
        print_message "Yay installed successfully as fallback!"
    fi
    cd "$SCRIPT_DIR"
    print_message "Paru installed successfully!"
else
    print_message "Paru is already installed."
fi

# Install all system packages with paru
print_message "Installing system packages with paru..."
PACKAGES=(
    hyprland
    ly
    kitty
    xdg-user-dirs
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    polkit
    hyprpolkitagent
    pipewire
    wireplumber
    pipewire-pulse
    pipewire-alsa
    brightnessctl
    swaync
    libnotify
    wofi
    waybar
    hyprpaper
    hypridle
    hyprlock
    hyprsunset
    hyprshot
    wl-clipboard
    noto-fonts
    noto-fonts-emoji
    ttf-meslo-nerd-font-powerlevel10k
    imv
    mpv
    zip
    unzip
    tar
    gzip
    ripgrep
    curl
    wget
    ffmpeg
    flatpak
    thunar
    udiskie
    pwvucontrol
    networkmanager
    power-profiles-daemon
    less
    man
    bc
    yazi
    p7zip
    poppler
    jq
    fzf
    zoxide
    resvg
    imagemagick
    fd
    okular
    nwg-look-bin
    jdk21-openjdk
    tealdeer
    xournalpp
    gnome-disk-utility
    gamescope
    opentabletdriver
    tmux
    btop
    stow
    bat
    starship
    fastfetch
    helix
    cups
    cups-pdf
    system-config-printer
    bluez
    bluez-utils
    blueman
    gvfs
    gvfs-mtp
    gvfs-gphoto2
    gvfs-afc
    ntfs-3g
    exfat-utils
    sshfs
    rsync
    firewalld
    pacman-contrib
    playerctl
)

if ! paru -S --needed --noconfirm "${PACKAGES[@]}"; then
    print_error "Failed to install one or more system packages."
    print_error "Please check the output above for details."
    exit 1
fi

print_message "All system packages installed successfully!"

# Install GPU drivers based on user selection
if [ "$GPU_TYPE" != "none" ]; then
    print_message "Installing GPU drivers for $GPU_TYPE..."
    
    case $GPU_TYPE in
        amd)
            GPU_PACKAGES=(
                mesa
                lib32-mesa
                vulkan-radeon
                lib32-vulkan-radeon
                libva-mesa-driver
                lib32-libva-mesa-driver
                mesa-vdpau
                lib32-mesa-vdpau
            )
            if ! paru -S --needed --noconfirm "${GPU_PACKAGES[@]}"; then
                print_error "Failed to install AMD GPU drivers"
                exit 1
            fi
            print_message "AMD GPU drivers installed successfully!"
            ;;
        nvidia)
            GPU_PACKAGES=(
                nvidia
                nvidia-utils
                lib32-nvidia-utils
                nvidia-settings
                egl-wayland
            )
            if ! paru -S --needed --noconfirm "${GPU_PACKAGES[@]}"; then
                print_error "Failed to install NVIDIA GPU drivers"
                exit 1
            fi
            
            # Enable nvidia modules
            print_message "Configuring NVIDIA modules..."
            sudo sh -c 'echo "options nvidia-drm modeset=1" > /etc/modprobe.d/nvidia.conf'
            
            # Add nvidia modules to mkinitcpio
            if grep -q "^MODULES=" /etc/mkinitcpio.conf; then
                sudo sed -i 's/^MODULES=.*/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
            else
                echo "MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" | sudo tee -a /etc/mkinitcpio.conf
            fi
            
            # Regenerate initramfs
            print_message "Regenerating initramfs..."
            sudo mkinitcpio -P
            
            print_message "NVIDIA GPU drivers installed and configured successfully!"
            print_warning "IMPORTANT: You may need to add 'nvidia-drm.modeset=1' to your kernel parameters"
            ;;
        intel)
            GPU_PACKAGES=(
                mesa
                lib32-mesa
                vulkan-intel
                lib32-vulkan-intel
                libva-intel-driver
                lib32-libva-intel-driver
                intel-media-driver
            )
            if ! paru -S --needed --noconfirm "${GPU_PACKAGES[@]}"; then
                print_error "Failed to install Intel GPU drivers"
                exit 1
            fi
            print_message "Intel GPU drivers installed successfully!"
            ;;
    esac
fi

# Generate XDG user directories
print_message "Generating XDG user directories..."
if ! xdg-user-dirs-update; then
    print_warning "Failed to generate XDG user directories, but continuing..."
fi

# Setup Flatpak
print_message "Setting up Flatpak..."
if ! sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; then
    print_error "Failed to add Flathub repository."
    exit 1
fi

# Install Flatpak applications
print_message "Installing Flatpak applications..."
FLATPAK_APPS=(
    com.discordapp.Discord
    com.github.tchx84.Flatseal
    com.bitwarden.desktop
    io.github.Faugus.faugus-launcher
    com.github.jeromerobert.pdfarranger
    com.github.PintaProject.Pinta
    org.localsend.localsend_app
    org.onlyoffice.desktopeditors
    io.github.flattool.Warehouse
)

FAILED_FLATPAKS=()
for app in "${FLATPAK_APPS[@]}"; do
    print_message "Installing $app..."
    if ! flatpak install -y flathub "$app"; then
        print_warning "Failed to install $app"
        FAILED_FLATPAKS+=("$app")
    fi
done

if [ ${#FAILED_FLATPAKS[@]} -gt 0 ]; then
    print_warning "The following Flatpak apps failed to install:"
    for app in "${FAILED_FLATPAKS[@]}"; do
        echo "  - $app"
    done
    print_warning "You may need to install these manually later."
else
    print_message "All Flatpak applications installed successfully!"
fi

# Copy configuration files
print_message "Copying configuration files..."

# Create .bashrc in home directory
print_message "Creating .bashrc (will overwrite if exists)..."
cat > "$HOME/.bashrc" << 'EOF'
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias rg='rg -S'
PS1='[\u@\h \W]\$ '
alias hx=helix
alias i='paru -S'
alias u='paru -Syu'
alias r='paru -Rns'
alias sr='paru -Ss'
alias ss='paru -Q | rg'
alias news='paru -Pww'

# Initialize starship prompt
eval "$(starship init bash)"

# Set default editor
export EDITOR="/usr/bin/helix"
export VISUAL="/usr/bin/helix"

# Initialize fzf key bindings and fuzzy completion
eval "$(fzf --bash)"

# Initialize zoxide (smart cd) - must be at the end
eval "$(zoxide init bash)"
EOF

if [ $? -ne 0 ]; then
    print_error "Failed to create .bashrc"
    exit 1
fi

print_message ".bashrc created successfully!"

# Create .config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Copy all config directories
print_message "Copying config directories (will overwrite existing configs)..."

# Copy backgrounds
if [ -d "$CONFIG_DIR/backgrounds" ]; then
    mkdir -p "$HOME/.config/backgrounds"
    cp -rf "$CONFIG_DIR/backgrounds/"* "$HOME/.config/backgrounds/"
    print_message "Backgrounds copied."
fi

# Copy btop config
if [ -d "$CONFIG_DIR/btop" ]; then
    mkdir -p "$HOME/.config/btop"
    cp -rf "$CONFIG_DIR/btop/"* "$HOME/.config/btop/"
    print_message "btop config copied."
fi

# Copy fastfetch config
if [ -d "$CONFIG_DIR/fastfetch" ]; then
    mkdir -p "$HOME/.config/fastfetch"
    cp -rf "$CONFIG_DIR/fastfetch/"* "$HOME/.config/fastfetch/"
    print_message "fastfetch config copied."
fi

# Copy helix config
if [ -d "$CONFIG_DIR/helix" ]; then
    mkdir -p "$HOME/.config/helix"
    cp -rf "$CONFIG_DIR/helix/"* "$HOME/.config/helix/"
    print_message "helix config copied."
fi

# Copy hypr configs
if [ -d "$CONFIG_DIR/hypr" ]; then
    mkdir -p "$HOME/.config/hypr"
    cp -rf "$CONFIG_DIR/hypr/"* "$HOME/.config/hypr/"
    print_message "hypr configs copied."
fi

# Copy kitty config
if [ -d "$CONFIG_DIR/kitty" ]; then
    mkdir -p "$HOME/.config/kitty"
    cp -rf "$CONFIG_DIR/kitty/"* "$HOME/.config/kitty/"
    print_message "kitty config copied."
fi

# Copy starship config
if [ -f "$CONFIG_DIR/starship.toml" ]; then
    cp -f "$CONFIG_DIR/starship.toml" "$HOME/.config/starship.toml"
    print_message "starship config copied."
fi

# Copy waybar config
if [ -d "$CONFIG_DIR/waybar" ]; then
    mkdir -p "$HOME/.config/waybar"
    cp -rf "$CONFIG_DIR/waybar/"* "$HOME/.config/waybar/"
    print_message "waybar config copied."
fi

# Copy wofi config
if [ -d "$CONFIG_DIR/wofi" ]; then
    mkdir -p "$HOME/.config/wofi"
    cp -rf "$CONFIG_DIR/wofi/"* "$HOME/.config/wofi/"
    print_message "wofi config copied."
fi

# Copy yazi config
if [ -d "$CONFIG_DIR/yazi" ]; then
    mkdir -p "$HOME/.config/yazi"
    cp -rf "$CONFIG_DIR/yazi/"* "$HOME/.config/yazi/"
    print_message "yazi config copied."
fi

print_message "All configuration files copied successfully!"

# Enable systemd services
print_message "Enabling systemd services..."

# Enable ly (display manager)
if ! sudo systemctl enable ly.service; then
    print_warning "Failed to enable ly.service"
fi

# Enable NetworkManager
if ! sudo systemctl enable NetworkManager.service; then
    print_warning "Failed to enable NetworkManager.service"
fi
if ! sudo systemctl start NetworkManager.service; then
    print_warning "Failed to start NetworkManager.service"
fi

# Enable power-profiles-daemon
if ! sudo systemctl enable power-profiles-daemon.service; then
    print_warning "Failed to enable power-profiles-daemon.service"
fi
if ! sudo systemctl start power-profiles-daemon.service; then
    print_warning "Failed to start power-profiles-daemon.service"
fi

# Enable CUPS (printing service)
if ! sudo systemctl enable cups.service; then
    print_warning "Failed to enable cups.service"
fi
if ! sudo systemctl start cups.service; then
    print_warning "Failed to start cups.service"
fi

# Enable Bluetooth
if ! sudo systemctl enable bluetooth.service; then
    print_warning "Failed to enable bluetooth.service"
fi
if ! sudo systemctl start bluetooth.service; then
    print_warning "Failed to start bluetooth.service"
fi

# Enable firewalld
if ! sudo systemctl enable firewalld.service; then
    print_warning "Failed to enable firewalld.service"
fi
if ! sudo systemctl start firewalld.service; then
    print_warning "Failed to start firewalld.service"
fi

# Enable udiskie user service for automounting
print_message "Setting up udiskie for automatic USB mounting..."
mkdir -p "$HOME/.config/systemd/user"
cat > "$HOME/.config/systemd/user/udiskie.service" << 'EOF'
[Unit]
Description=Udiskie automount daemon

[Service]
ExecStart=/usr/bin/udiskie --tray
Restart=on-failure

[Install]
WantedBy=default.target
EOF

if ! systemctl --user enable udiskie.service; then
    print_warning "Failed to enable udiskie.service"
fi

# Enable pipewire services (user services)
if ! systemctl --user enable pipewire.service; then
    print_warning "Failed to enable pipewire.service"
fi
if ! systemctl --user enable pipewire-pulse.service; then
    print_warning "Failed to enable pipewire-pulse.service"
fi
if ! systemctl --user enable wireplumber.service; then
    print_warning "Failed to enable wireplumber.service"
fi

# Start pipewire services
if ! systemctl --user start pipewire.service; then
    print_warning "Failed to start pipewire.service"
fi
if ! systemctl --user start pipewire-pulse.service; then
    print_warning "Failed to start pipewire-pulse.service"
fi
if ! systemctl --user start wireplumber.service; then
    print_warning "Failed to start wireplumber.service"
fi

print_message "Systemd services configuration completed!"

# Enable paccache timer for automatic package cache cleanup
print_message "Enabling automatic package cache cleanup..."
if ! sudo systemctl enable paccache.timer; then
    print_warning "Failed to enable paccache.timer"
fi

# Setup tealdeer cache
print_message "Updating tealdeer cache..."
tldr --update || print_warning "Failed to update tealdeer cache, but continuing..."

# Set permissions on config files
print_message "Setting correct permissions on config files..."
chmod 644 "$HOME/.bashrc"
find "$HOME/.config" -type f -exec chmod 644 {} \;
find "$HOME/.config" -type d -exec chmod 755 {} \;

# Delete Arch-Setup directory if requested
if [ "$DELETE_AFTER_SETUP" = true ]; then
    print_message "Deleting Starch directory as requested..."
    cd "$HOME"
    if rm -rf "$SCRIPT_DIR"; then
        print_message "Starch directory deleted successfully!"
    else
        print_warning "Failed to delete Starch directory. You may need to delete it manually."
    fi
fi

# Final message
print_message ""
print_message "=========================================="
print_message "Setup completed successfully!"
print_message "=========================================="
print_message ""
print_message "Please reboot your system to apply all changes."
print_message "After reboot, you should see the ly display manager."
print_message ""
print_warning "Note: You may need to configure some applications manually:"
print_message "  - Hyprland: Review ~/.config/hypr/hyprland.conf"
print_message "  - Display manager: ly is enabled and will start on boot"
print_message "  - OpenTabletDriver: May need configuration via GUI"
print_message "  - Printing: Access printer settings via system-config-printer"
print_message "  - Bluetooth: Manage devices via blueman (system tray icon)"
print_message "  - Firewall: Manage rules via firewall-config or firewall-cmd"
print_message ""
print_message "Installed services:"
print_message "  ✓ CUPS (printing)"
print_message "  ✓ Bluetooth"
print_message "  ✓ Firewalld (firewall)"
print_message "  ✓ Network Manager"
print_message "  ✓ Power Profiles"
print_message "  ✓ PipeWire (audio)"
print_message "  ✓ Udiskie (USB automount)"
print_message "  ✓ Paccache (automatic cache cleanup)"
if [ "$GPU_TYPE" != "none" ]; then
    print_message "  ✓ GPU Drivers ($GPU_TYPE)"
fi
print_message ""
print_message "To reboot now, run: sudo reboot"
