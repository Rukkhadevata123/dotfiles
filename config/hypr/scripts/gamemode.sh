#!/usr/bin/env sh

HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ] ; then
    # 启用游戏模式
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"
    
    # 切换到性能模式
    powerprofilesctl set performance 2>/dev/null || echo "PowerProfiles not available"
    
    notify-send "🎮 游戏模式" "已启用 - 性能优化模式\n🔋 电源配置: 性能模式" -t 3000 -u normal
    exit
fi

# 禁用游戏模式
hyprctl reload

# 恢复平衡模式
powerprofilesctl set balanced 2>/dev/null || echo "PowerProfiles not available"

notify-send "🖥️ 游戏模式" "已禁用 - 恢复桌面效果\n🔋 电源配置: 平衡模式" -t 3000 -u normal