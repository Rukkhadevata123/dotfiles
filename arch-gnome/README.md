# Arch Linux / GNOME 配置快照

基础采集日期：2026-10-22；2026-10-23 补充 Chrome 的 NVIDIA 视频硬解配置。环境为 GNOME 51.1、Fcitx5 + Kimpanel、Qt6ct + Kvantum（KvFlat）。本目录保存可复用配置和采集时的软件包状态。

| 路径 | 内容 |
| --- | --- |
| `home/` | 按家目录结构保存的 Zsh、Starship、字体、Fcitx5、GTK、Qt6ct、Kvantum、VS Code、MangoHud、htop、Chrome 启动参数、自启动和 QQ 启动器配置 |
| `gnome/settings.dconf` | 筛选后的 GNOME 用户设置，包括外观、鼠标/触摸板、电源、快捷键、收藏应用和扩展设置 |
| `gnome/extensions.json` | GNOME 扩展 UUID、来源、版本和兼容的 Shell 版本；不包含扩展源码 |
| `packages/` | 显式包、仓库/外部包分类、全部已安装包版本、反向依赖和 VS Code 扩展清单 |
| `system/` | pacman、语言配置和 systemd 启用链接的参考记录 |
| `machine-specific/home/` | 单独存放的显示器布局、LACT UI 和游戏启动脚本 |
| `audit.md` | 当前配置细节和包安装原因分析 |
| `snapshot.json` | 采集时间、数量、来源路径及筛选说明 |

字体顺序保留为 HarmonyOS Sans SC；等宽优先 Inconsolata Nerd Font Mono，其次 CaskaydiaCove Nerd Font Mono。GNOME 字体设置和 Fontconfig 的别名规则分别留档。字体文件由软件包提供，不在仓库中另存副本。

## 软件包记录

- `explicit.txt`：`pacman -Qqe`，103 个显式包。
- `explicit-native.txt`：`pacman -Qqen`，94 个当前同步仓库中的显式包。
- `explicit-foreign.txt`：`pacman -Qqem`，9 个当前同步仓库之外的显式包，通常来自 AUR 或本地构建。
- `installed-versions.txt`：`pacman -Q`，全部 848 个已安装包的名称和版本。
- `explicit-dependencies.tsv`：每个显式包的 `Required By`、`Optional For` 和描述。
- `orphans.txt`：`pacman -Qdtq` 的结果，本次为空。
- `vscode-extensions.txt` / `vscode-extension-versions.json`：9 个 VS Code 扩展的 ID，以及采集时的版本。

这些清单记录本机的选择，不是 GNOME 最小安装清单，也不是版本锁文件。重建系统时先核对硬件和开发工具需求，再安装需要的项目。确认采用完整仓库包清单后，可在本目录运行：

```sh
sudo pacman -Syu --needed - < packages/explicit-native.txt
```

外部包清单另行检查，用 AUR 助手或原来的构建方式安装。`installed-versions.txt` 用于查证当时版本，不用于逐包降级或将全部依赖改成显式安装。GNOME 会话、Nautilus、Portal 等当前由依赖链安装，因此不一定出现在显式包清单中。

## Chrome / NVIDIA 视频硬解

2026-10-23 已在 RTX 4050 Laptop GPU 独显直连、NVIDIA 615.78.08、GNOME Wayland、Google Chrome 156.0.8078.47 和 `libva-nvidia-driver` 0.0.18 上验证视频硬解可用。`home/.config/chrome-flags.conf` 保存启动参数；本机此模式下不需要显式设置 `LIBVA_DRIVER_NAME` 或 `NVD_BACKEND`。

恢复时先安装 `google-chrome`（AUR），再安装 VA-API 驱动及诊断工具：

```sh
sudo pacman -S --needed libva-nvidia-driver libva-utils
```

软件包清单仍记录 2026-10-22 的基础快照，其中浏览器为 Chromium；恢复本节配置时选择 Google Chrome，并补装上述包。当前安装的 Google Chrome 启动脚本读取 `~/.config/chrome-flags.conf`。

按下方命令恢复 `home/` 后，完全退出 Chrome（包括后台进程）再启动。播放视频时用 `chrome://media-internals` 检查实际解码器，并确认 `chrome://gpu` 的 `Video Acceleration Information` 列出了具体解码能力。该配置用于视频解码，编码能力另行确认。

## 恢复用户配置

先安装相应程序和字体。Kimpanel 通过 Extension Manager 安装 `kimpanel@kde.org`；AppIndicator 对应 `gnome-shell-extension-appindicator`。新系统应选择兼容当前 GNOME 版本的扩展。

在本目录预览将复制的文件：

```sh
rsync -av --dry-run home/ "$HOME/"
```

确认后备份被覆盖的同名文件并复制。这里没有使用 `--delete`，其他个人文件会保留：

```sh
arch_gnome_backup="$HOME/.local/state/arch-gnome-restore/$(date +%Y%m%d-%H%M%S)"
mkdir -p -m 700 "$arch_gnome_backup"
rsync -av --backup --backup-dir="$arch_gnome_backup" home/ "$HOME/"
fc-cache -f
```

在自己的 GNOME 终端中备份当前 dconf，再导入筛选后的设置：

```sh
dconf dump / > "$arch_gnome_backup/dconf-before.ini"
dconf load / < gnome/settings.dconf
```

这会合并文件中的键，不会重置整个 dconf。备份包含本机用户设置，保存在上述家目录状态文件夹里即可。导入前先安装扩展；完成后注销再登录，使环境变量和桌面扩展完整生效。

如需恢复 VS Code 扩展，可在安装 VS Code 后运行：

```sh
while IFS= read -r extension_id; do
    code --install-extension "$extension_id" || break
done < packages/vscode-extensions.txt
```

## 需要单独决定的部分

`machine-specific/home/.config/monitors.xml` 包含本机双屏布局、刷新率和缩放。LACT UI 绑定本机 GPU；游戏脚本依赖原来的游戏目录、DWProton 和工具。它们不会随上面的 `home/` 命令复制，按需要单独取用。

`system/` 只供核对。恢复系统语言时根据 `locale-gen-enabled.txt` 编辑 `/etc/locale.gen` 并运行 `sudo locale-gen`；pacman 配置和服务也应结合新系统逐项设置。`enabled-services.tsv` 记录启用链接，不代表服务正在运行。

没有收录浏览器资料、代理订阅和节点、账号/令牌、密钥环、钱包、Git 身份、输入法用户词库、历史记录、壁纸、缓存或日志。输入法词库如需迁移，应另外私下备份 `~/.local/share/fcitx5/`。

Qt6ct 的副本仅去掉设置窗口的几何信息，其他选项按现状保留。GNOME 的 dconf 只保存选定的用户设置，省略窗口状态、应用网格布局和历史。
