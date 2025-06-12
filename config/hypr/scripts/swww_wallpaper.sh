#!/bin/bash

WALLPAPER_DIR="$HOME/dotfiles/config/hypr/wallpapers"
SLIDESHOW_LOCK="/tmp/swww_slideshow.lock"
SLIDESHOW_INTERVAL=600  # 10分钟，测试时可改为5

# swww 过渡效果设置
export SWWW_TRANSITION_FPS=144
export SWWW_TRANSITION_STEP=2
export SWWW_TRANSITION_TYPE=random
export SWWW_TRANSITION_DURATION=1

# 初始化 - 等待缩放设置后启动
init_wallpaper() {
    # 等待 DPI 缩放生效
    sleep 2
    
    # 启动 swww-daemon
    swww-daemon &
    sleep 1
    
    # 设置默认壁纸
    local default_wall=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | head -n1)
    if [[ -f "$default_wall" ]]; then
        swww img "$default_wall" 2>/dev/null
    fi
}

# 设置壁纸
set_wallpaper() {
    local wallpaper="$1"
    [[ -f "$wallpaper" ]] || return 1
    
    if swww img "$wallpaper" 2>/dev/null; then
        notify-send "壁纸已更换" "$(basename "$wallpaper")" -t 2000
    else
        notify-send "壁纸错误" "设置失败" -t 2000
        return 1
    fi
}

# 获取随机壁纸
get_random_wallpaper() {
    local current_wall=$(swww query 2>/dev/null | grep -o '/.*\.\(jpg\|jpeg\|png\|webp\)' | head -n1)
    local wallpapers=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \)))
    
    [[ ${#wallpapers[@]} -eq 0 ]] && { notify-send "壁纸错误" "未找到壁纸文件" -t 3000; return 1; }
    [[ ${#wallpapers[@]} -eq 1 ]] && { echo "${wallpapers[0]}"; return 0; }
    
    # 尝试选择不同的壁纸
    for i in {1..5}; do
        local random_wall="${wallpapers[$((RANDOM % ${#wallpapers[@]}))]}"
        [[ "$random_wall" != "$current_wall" ]] && { echo "$random_wall"; return 0; }
    done
    
    echo "${wallpapers[0]}"
}

# 随机切换壁纸
random_wallpaper() {
    if [[ -f "$SLIDESHOW_LOCK" ]]; then
        notify-send "壁纸切换" "幻灯片模式运行中，请先停止" -t 2000
        return 1
    fi
    
    local new_wall=$(get_random_wallpaper)
    [[ -n "$new_wall" ]] && set_wallpaper "$new_wall"
}

# 检查幻灯片状态
is_slideshow_running() {
    [[ -f "$SLIDESHOW_LOCK" ]]
}

# 幻灯片循环 - 基于 wiki 脚本
slideshow_loop() {
    echo $$ > "$SLIDESHOW_LOCK"
    trap 'rm -f "$SLIDESHOW_LOCK"; exit 0' TERM INT EXIT
    
    while [[ -f "$SLIDESHOW_LOCK" ]]; do
        find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
            | while read -r img; do
                echo "$((RANDOM % 1000)):$img"
            done \
            | sort -n | cut -d':' -f2- \
            | while read -r img; do
                [[ ! -f "$SLIDESHOW_LOCK" ]] && break
                
                if [[ "$img" != "$WALLPAPER_DIR" && -f "$img" ]]; then
                    swww img "$img" 2>/dev/null
                    
                    # 等待间隔
                    local count=0
                    while [[ $count -lt $SLIDESHOW_INTERVAL ]] && [[ -f "$SLIDESHOW_LOCK" ]]; do
                        sleep 1
                        ((count++))
                    done
                fi
                
                [[ ! -f "$SLIDESHOW_LOCK" ]] && break
            done
    done
}

# 启动幻灯片
start_slideshow() {
    if is_slideshow_running; then
        notify-send "幻灯片播放" "已在运行中" -t 2000
        return 0
    fi
    
    slideshow_loop &
    sleep 0.5
    
    if is_slideshow_running; then
        notify-send "幻灯片播放" "已启动 (间隔: ${SLIDESHOW_INTERVAL}s)" -t 2000
    else
        notify-send "幻灯片播放" "启动失败" -t 2000
    fi
}

# 停止幻灯片
stop_slideshow() {
    if [[ -f "$SLIDESHOW_LOCK" ]]; then
        local pid=$(cat "$SLIDESHOW_LOCK" 2>/dev/null)
        rm -f "$SLIDESHOW_LOCK"
        
        [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null && {
            kill -TERM "$pid" 2>/dev/null
            sleep 1
            kill -0 "$pid" 2>/dev/null && kill -KILL "$pid" 2>/dev/null
        }
        
        notify-send "幻灯片播放" "已停止" -t 2000
    else
        notify-send "幻灯片播放" "未在运行" -t 2000
    fi
}

# 切换幻灯片状态
toggle_slideshow() {
    if is_slideshow_running; then
        stop_slideshow
    else
        start_slideshow
    fi
}

# 清理函数
cleanup() {
    pkill -f "swww_wallpaper.sh" 2>/dev/null || true
    rm -f "$SLIDESHOW_LOCK"
    notify-send "壁纸管理" "已清理" -t 2000
}

# 主逻辑
case "$1" in
    "init")
        init_wallpaper
        ;;
    "random")
        random_wallpaper
        ;;
    "slideshow-start")
        start_slideshow
        ;;
    "slideshow-stop")
        stop_slideshow
        ;;
    "slideshow-toggle")
        toggle_slideshow
        ;;
    "folder")
        nautilus "$WALLPAPER_DIR" &
        ;;
    "status")
        is_slideshow_running && echo "running" || echo "stopped"
        ;;
    "cleanup")
        cleanup
        ;;
    *)
        echo "Usage: $0 {init|random|slideshow-start|slideshow-stop|slideshow-toggle|folder|status|cleanup}"
        exit 1
        ;;
esac