#!/bin/bash
# Applications & Development Setup

set -e

echo "=== Applications & Development Setup ==="

# Development tools
yay -S rustup go jdk21-openjdk npm nodejs base-devel visual-studio-code-bin
rustup install stable
cargo install cargo-xwin

# Software collection
yay -S qbittorrent plocate lutris wine winetricks zenity gimp blender flatpak xdg-desktop-portal flatpak-kcm steam wechat-universal-bwrap linuxqq wps-office-365 google-chrome flameshot obs-studio ffmpeg texlive vlc mpv yt-dlp fastfetch octopi bleachbit 7zip vulkan-devel vulkan-headers vulkan-tools imagemagick swtpm appmenu-gtk-module libdbusmenu-glib mpd

echo "=== Manual tasks ==="
echo "1. Generate SSH key: ssh-keygen"
echo "2. Add to GitHub: cat ~/.ssh/id_ed25519.pub"
echo "3. Test connection: ssh -T git@github.com"
echo "4. Create Python environment: python3 -m venv base_python_env"

echo "=== Applications setup completed ==="