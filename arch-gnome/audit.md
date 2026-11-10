# 扫描记录：2026-11-10

## 已保存的当前选择

- GNOME：青绿色强调色、启用热角、深色偏好、`adw-gtk3-dark`、Adwaita 图标、32 像素光标；光标主题没有用户覆盖，当前默认值为 Adwaita。
- GNOME 界面/文档字体：`HarmonyOS Sans 12`；系统等宽：`Inconsolata Nerd Font Mono 16`。Fontconfig 为中文指定 `HarmonyOS Sans SC`，保留 Inconsolata → Caskaydia → 中文字体的回退顺序。
- Qt：`QT_QPA_PLATFORMTHEME=qt6ct`，Qt6ct 的样式为 `kvantum`，Kvantum 主题为内置 `KvFlat`。
- 输入法：Fcitx5 的美式键盘 + 拼音，环境变量和自启动均已保存。百度云拼音已启用，并开启云候选占位符。Kimpanel 字体为 `HarmonyOS Sans SC 14`。
- GNOME 扩展：Kimpanel、Tiling Assistant（用户安装）和 AppIndicator（软件包安装），详见 `gnome/extensions.json`。
- 截图快捷键：`Super+Print` 调用 `gradia --screenshot=INTERACTIVE`；`Ctrl+Alt+T` 调用 `kgx`，两项均已保存。`gst-plugin-pipewire` 仍为显式安装，也已进入包清单。
- 电源：空闲延时为 0，交流电和电池空闲动作均为 `nothing`；这是当前设置，快照原样保留。

## 外观设置的适用范围

GTK3/4 的 `settings.ini` 当前都写有 `gtk-application-prefer-dark-theme=0`，而 GNOME 的颜色偏好为 `prefer-dark`。这些设置控制的层面和应用支持情况不同，本次保留原状；以后若某些应用颜色不一致，可从这里检查。

Fcitx5 Classic UI 配置仍写 `Noto Sans 12`，而 GNOME Kimpanel 自己使用 14 号鸿蒙字体。在 Kimpanel 生效时，应调整扩展的字体设置；Classic UI 的配置用于它接管候选框时的外观。

## 显式包与依赖

全部 857 个包中，102 个显式安装：91 个在当前同步仓库，11 个在仓库之外。`pacman -Qdtq` 没有结果。

当前显式包中，只有 `linux-zen` 同时被其他包必需依赖，其 `Required By` 为 `ntsync-autoload`。保留本机安装原因，不据此调整标记。

`aspnet-targeting-pack`、`git`、`gnome-shell`、`openssh` 和 `pacman-contrib` 当前仍已安装，但已不在显式包清单中。开发环境包含 .NET SDK，VS Code 的容器客户端设置为 Podman；本机扩展清单为 C#、.NET Install Tool、Container Tools 和 Dev Containers，共 4 个。

本次没有执行 `pacman -D --asdeps`、卸载或安装操作。没有反向必需依赖的包也不等于多余，例如软件、开发头文件、驱动和可选功能可能是主动安装的。全部显式包的必需/可选反向依赖见 `packages/explicit-dependencies.tsv`。

NetworkManager 仍为显式包。`gnome-session`、`nautilus`、`xdg-desktop-portal-gnome` 当前作为依赖安装，并未缺失。

系统启用链接包括 GDM、NetworkManager、chronyd、蓝牙、电源管理、LACT、NVIDIA、GNOME Remote Desktop、SSHD 和 Tailscale 相关服务。休眠及挂起相关的 5 个 target 指向 `/dev/null`，属于屏蔽项。完整记录在 `system/enabled-services.tsv`；本次未改变服务状态。

## 配置与安装状态的差异

用户和系统扩展目录中均未找到 `blur-my-shell@aunetx`，已按用户要求从本机及快照的 `enabled-extensions` 中移除这一残留项。当前启用列表与记录的 3 个已安装扩展一致。Tiling Assistant 的快捷键和外观设置已保存，内部版本记录和被覆盖设置的备份未收录。

默认浏览器关联已改为 Google Chrome；MIME 关联、自启动和收藏应用中仍可能保留其他程序的旧条目，本次未改动实际配置。

显示器布局已刷新；胡桃游戏启动脚本中的依赖文件名由 `hutao_minhook_ng.dll` 改为 `hutao-minhook-ng.dll`。这些文件仍放在 `machine-specific/`，未测试游戏启动。
