#!/bin/bash
# Desktop Environment Setup

set -e

echo "=== Desktop Environment Setup ==="

# GNOME Extensions
yay -S extension-manager gnome-shell-extension-blur-my-shell gnome-shell-extension-dash-to-dock gnome-shell-extension-easyscreencast gnome-shell-extension-gnome-ui-tune-git gnome-shell-extension-gsconnect gnome-shell-extension-just-perfection-desktop gnome-shell-extension-kimpanel-git gnome-shell-extension-extension-list

sudo pacman -S gnome-browser-connector gnome-shell-extension-appindicator gnome-shell-extension-desktop-icons-ng gnome-shell-extensions

# GNOME settings
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'kms-modifiers', 'autoclose-xwayland', 'variable-refresh-rate', 'xwayland-native-scaling']"

# Hyprland packages
yay -S swww wob network-manager-applet zenity ark rar hyprshell xdotool swaylock-effects sweet-cursors-hyprcursor-git nordzy-hyprcursors xcursor-pro-hyprcursor hyprcursor-dracula-kde-git swaybg btop wlogout hyprsunset hyprlock hyprpaper brightnessctl cliphist wl-clipboard grim slurp wl-clip-persist nautilus-admin-gtk4 nautilus-image-converter nautilus-open-any-terminal hyprpicker wf-recorder pavucontrol bluetui xwayland-satellite nwg-dock-hyprland nwg-drawer swaync blueman notification-daemon swaylock-effects --needed

# QT Integration
sudo pacman -S kvantum xsettingsd
echo 'QT_STYLE_OVERRIDE=kvantum' | sudo tee -a /etc/environment

# Themes and Icons
yay -S orchis-theme papirus-icon-theme papirus-folders bibata-cursor-theme nwg-look
papirus-folders -C brown --theme Papirus-Light

# Input Method
sudo pacman -S fcitx5-im fcitx5-chinese-addons fcitx5-configtool
yay -S fcitx5-pinyin-sougou-dict-git fcitx5-pinyin-zhwiki fcitx5-pinyin-moegirl
echo 'QT_IM_MODULE=fcitx' | sudo tee -a /etc/environment
echo 'XMODIFIERS=@im=fcitx' | sudo tee -a /etc/environment

# Fonts
sudo usermod -aG disk $USER
echo "Please logout and login again, then run:"
echo "yay -S ttf-ms-win11-auto-zh_cn --noconfirm"

# Essential fonts
sudo pacman -S otf-codenewroman-nerd otf-aurulent-nerd otf-codenewroman-nerd otf-comicshanns-nerd otf-commit-mono-nerd otf-droid-nerd otf-firamono-nerd otf-geist-mono-nerd otf-hasklig-nerd otf-hermit-nerd otf-monaspace-nerd otf-opendyslexic-nerd otf-overpass-nerd ttf-0xproto-nerd ttf-3270-nerd ttf-agave-nerd ttf-anonymouspro-nerd ttf-arimo-nerd ttf-bigblueterminal-nerd ttf-bitstream-vera-mono-nerd ttf-cascadia-code ttf-cascadia-code-nerd ttf-cascadia-mono-nerd ttf-cousine-nerd ttf-d2coding-nerd ttf-daddytime-mono-nerd ttf-dejavu-nerd ttf-envycoder-nerd ttf-fantasque-nerd ttf-firacode-nerd ttf-go-nerd ttf-gohu-nerd ttf-hack-nerd ttf-heavydata-nerd ttf-iawriter-nerd ttf-ibmplex-mono-nerd ttf-inconsolata-go-nerd ttf-inconsolata-lgc-nerd ttf-inconsolata-nerd ttf-input-nerd ttf-intone-nerd ttf-iosevka-nerd ttf-iosevkaterm-nerd ttf-iosevkatermslab-nerd ttf-jetbrains-mono-nerd ttf-lekton-nerd ttf-liberation-mono-nerd ttf-lilex-nerd ttf-martian-mono-nerd ttf-meslo-nerd ttf-monofur-nerd ttf-monoid-nerd ttf-mononoki-nerd ttf-mplus-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common ttf-nerd-fonts-symbols-mono ttf-noto-nerd ttf-profont-nerd ttf-proggyclean-nerd ttf-recursive-nerd ttf-roboto-mono-nerd ttf-sharetech-mono-nerd ttf-sourcecodepro-nerd ttf-space-mono-nerd ttf-terminus-nerd ttf-tinos-nerd ttf-ubuntu-mono-nerd ttf-ubuntu-nerd ttf-victor-mono-nerd ttf-zed-mono-nerd ttf-firacode-nerd ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd ttf-nerd-fonts-symbols-common gnu-free-fonts ttf-arphic-uming ttf-indic-otf noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts

# Copy font config
sudo cp system/fonts/conf.d/64-language-selector-prefer.conf /etc/fonts/conf.d/
fc-cache -fv

echo "=== Desktop setup completed ==="