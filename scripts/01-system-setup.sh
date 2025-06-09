#!/bin/bash
# System Configuration Setup
# Run this first, requires reboot after completion

set -e

echo "=== System Configuration Setup ==="

# Add archlinuxcn repository key
sudo pacman -S archlinuxcn-keyring

# Grub setup
sudo pacman -S os-prober efibootmgr

# Install GRUB theme
echo "=== Installing GRUB Theme ==="
sudo cp -r system/grub/Themes/Hyacine /usr/share/grub/themes/

echo "Please manually edit the following files using the examples in system/ directory:"
echo "- /etc/pacman.conf (add archlinuxcn repository)"
echo "- /etc/default/grub (copy from system/grub/grub, CAREFULLY CHECK ALL SETTINGS)"
echo ""
echo "IMPORTANT: For GRUB theme, add this line to /etc/default/grub:"
echo 'GRUB_THEME="/usr/share/grub/themes/Hyacine/theme.txt"'
echo ""
echo "WARNING: Please carefully review all GRUB settings before proceeding!"

read -p "Press Enter after editing the files..."

sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "=== System configuration completed. Please reboot before running 02-drivers-setup.sh ==="