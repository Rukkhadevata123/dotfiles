#!/bin/bash
# Hardware Drivers Setup
# Run after reboot from 01-system-setup.sh

set -e

echo "=== Hardware Drivers Setup ==="

# Base system packages
sudo pacman -S base-devel linux-zen-headers power-profiles-daemon gst-libav gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly gst-plugin-pipewire egl-wayland xdg-desktop-portal xdg-desktop-portal-wlr grim --needed

# Graphics and compute packages
sudo pacman -S --needed nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader lib32-mesa vulkan-intel lib32-vulkan-intel intel-compute-runtime hashcat cuda cuda-toolkit switcheroo-control switcheroo nvidia-prime libva-utils

# Enable services
sudo systemctl enable --now switcheroo-control
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service

echo "=== Driver verification commands ==="
echo "Run these to verify installation:"
echo "lsmod | grep kvm"
echo "cat /proc/driver/nvidia/params | grep PreserveVideoMemoryAllocations"
echo "sudo cat /sys/module/nvidia_drm/parameters/fbdev"
echo "sudo cat /sys/module/nvidia_drm/parameters/modeset"

echo "=== Drivers setup completed ==="