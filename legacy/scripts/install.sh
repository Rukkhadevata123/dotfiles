#!/bin/bash
# Dotfiles Installation Script

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Create necessary directories
mkdir -p ~/.config
mkdir -p ~/.local/share/dbus-1/services

# Zsh configuration
sudo pacman -S grml-zsh-config

# Link configuration files
ln -sf "$DOTFILES_DIR/.profile" ~/.profile
ln -sf "$DOTFILES_DIR/.gtkrc-2.0" ~/.gtkrc-2.0
ln -sf "$DOTFILES_DIR/.gtkrc-2.0.mine" ~/.gtkrc-2.0.mine
ln -sf "$DOTFILES_DIR/config/alacritty" ~/.config/
ln -sf "$DOTFILES_DIR/config/conky" ~/.config/
ln -sf "$DOTFILES_DIR/config/gtk-3.0" ~/.config/
ln -sf "$DOTFILES_DIR/config/gtk-4.0" ~/.config/
ln -sf "$DOTFILES_DIR/config/hypr" ~/.config/
ln -sf "$DOTFILES_DIR/config/hyprshell" ~/.config/
ln -sf "$DOTFILES_DIR/config/kitty" ~/.config/
ln -sf "$DOTFILES_DIR/config/Kvantum" ~/.config/
ln -sf "$DOTFILES_DIR/config/nwg-dock-hyprland" ~/.config/
ln -sf "$DOTFILES_DIR/config/nwg-drawer" ~/.config/
ln -sf "$DOTFILES_DIR/config/nwg-look" ~/.config/
ln -sf "$DOTFILES_DIR/config/swaync" ~/.config/
ln -sf "$DOTFILES_DIR/config/uwsm" ~/.config/
ln -sf "$DOTFILES_DIR/config/wob" ~/.config/
ln -sf "$DOTFILES_DIR/config/waybar" ~/.config/
ln -sf "$DOTFILES_DIR/config/wlogout" ~/.config/
ln -sf "$DOTFILES_DIR/config/wofi" ~/.config/
ln -sf "$DOTFILES_DIR/config/xsettingsd" ~/.config/
ln -sf "$DOTFILES_DIR/config/zsh/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/config/zsh/.p10k.zsh" ~/.p10k.zsh
ln -sf "$DOTFILES_DIR/config/electron-flags.conf" ~/.config/
ln -sf "$DOTFILES_DIR/config/chrome-flags.conf" ~/.config/
ln -sf "$DOTFILES_DIR/config/chromium-flags.conf" ~/.config/
ln -sf "$DOTFILES_DIR/config/code-flags.conf" ~/.config/

# Link system files
ln -sf "$DOTFILES_DIR/system/dbus-1/services/org.freedesktop.Notifications.service" ~/.local/share/dbus-1/services/

echo "Dotfiles linked successfully!"
echo "Run the setup scripts in order: 01-system-setup.sh -> 02-drivers-setup.sh -> etc."
