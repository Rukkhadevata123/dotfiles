# 扫描记录：2026-10-22

## 已保存的当前选择

- GNOME：深色偏好、`adw-gtk3-dark`、Adwaita 图标、32 像素光标；光标主题没有用户覆盖，当前默认值为 Adwaita。
- GNOME 界面/文档字体：`HarmonyOS Sans 12`；系统等宽：`Inconsolata Nerd Font Mono 16`。Fontconfig 为中文指定 `HarmonyOS Sans SC`，保留 Inconsolata → Caskaydia → 中文字体的回退顺序。
- Qt：`QT_QPA_PLATFORMTHEME=qt6ct`，Qt6ct 的样式为 `kvantum`，Kvantum 主题为内置 `KvFlat`。
- 输入法：Fcitx5 的美式键盘 + 拼音，环境变量和自启动均已保存。Kimpanel 字体为 `HarmonyOS Sans SC 14`。
- GNOME 扩展：Kimpanel（用户安装）和 AppIndicator（软件包安装），详见 `gnome/extensions.json`。
- 截图快捷键：`Super+Print` 调用 `gradia --screenshot=INTERACTIVE`；已保存。`gst-plugin-pipewire` 仍为显式安装，也已进入包清单。
- 电源：空闲延时为 0，交流电和电池空闲动作均为 `nothing`；这是当前设置，快照原样保留。

## 外观设置的适用范围

GTK3/4 的 `settings.ini` 当前都写有 `gtk-application-prefer-dark-theme=0`，而 GNOME 的颜色偏好为 `prefer-dark`。这些设置控制的层面和应用支持情况不同，本次保留原状；以后若某些应用颜色不一致，可从这里检查。

Fcitx5 Classic UI 配置仍写 `Noto Sans 12`，而 GNOME Kimpanel 自己使用 14 号鸿蒙字体。在 Kimpanel 生效时，应调整扩展的字体设置；Classic UI 的配置用于它接管候选框时的外观。

## 显式包与依赖

全部 848 个包中，103 个显式安装：94 个在当前同步仓库，9 个在仓库之外。`pacman -Qdtq` 没有结果。

以下 5 个显式包同时被其他包必需依赖：

| 包 | Required By | Optional For | 本次判断 |
| --- | --- | --- | --- |
| `git` | `git-lfs`、`yay` | `gettext`、`openai-codex` | 根据之前偏好保留显式 |
| `gnome-shell` | `gdm`、`gnome-control-center`、`gnome-shell-extension-appindicator` | 无 | 桌面主体，保留显式便于表达安装意图 |
| `openssh` | `gcr`、`gcr-4` | `git`、`gnome-control-center` | 可选依赖也保留显式 |
| `pacman-contrib` | `downgrade` | 无 | 若只由 downgrade 带入，可考虑标为依赖；也包含可独立使用的维护工具 |
| `vulkan-headers` | `vulkan-profiles` | 无 | 若仅随 vulkan-profiles 安装可标为依赖；独立开发用途则保留显式 |

本次没有执行 `pacman -D --asdeps`、卸载或安装操作。没有反向必需依赖的包也不等于多余，例如软件、开发头文件、驱动和可选功能可能是主动安装的。全部显式包的必需/可选反向依赖见 `packages/explicit-dependencies.tsv`。

NetworkManager 仍为显式包。`gnome-session`、`nautilus`、`xdg-desktop-portal-gnome` 当前作为依赖安装，并未缺失。

系统启用链接包括 GDM、NetworkManager、chronyd、蓝牙、电源管理、LACT 和 NVIDIA 相关服务，完整记录在 `system/enabled-services.tsv`；本次未改变服务状态。
