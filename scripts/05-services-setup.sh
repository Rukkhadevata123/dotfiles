#!/bin/bash
# System Services Setup

set -e

echo "=== System Services Setup ==="

# Memory management - Zram
sudo pacman -S zram-generator
sudo cp system/systemd/zram-generator.conf /etc/systemd/
sudo systemctl restart systemd-zram-setup@zram0.service

# Zram optimization
sudo cp system/sysctl.d/99-vm-zram-parameters.conf /etc/sysctl.d/

# Printing
yay -S cups
sudo systemctl enable --now cups

# Bluetooth
sudo pacman -S bluez bluez-utils
sudo systemctl enable --now bluetooth.service

# Virtualization
sudo pacman -S qemu-full libvirt virt-manager dnsmasq
sudo systemctl enable --now libvirtd

# Shell setup
sudo pacman -S zsh-autocomplete zsh-autosuggestions zsh-completions zsh-doc zsh-history-substring-search zsh-lovers zsh-syntax-highlighting zsh-theme-powerlevel10k-git pkgfile eza tree
sudo pkgfile --update

# System tweaks
echo 'vm.max_map_count = 2147483642' | sudo tee /etc/sysctl.d/80-gamecompatibility.conf
timedatectl set-local-rtc 0

# Audio permissions
sudo pacman -S realtime-privileges && sudo gpasswd -a $USER realtime

# Waybar permissions
sudo usermod -aG input $USER

echo "=== Manual tasks ==="
echo "1. Configure git: git config --global user.name 'Rukkhadevata123'"
echo "2. Configure git: git config --global user.email '3083913301@qq.com'"
echo "3. Optional proxy: git config --global http.proxy '127.0.0.1:7897'"

echo "=== Services setup completed ==="
echo "Please logout and login again to apply group changes"