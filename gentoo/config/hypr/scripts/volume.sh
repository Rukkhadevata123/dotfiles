#!/usr/bin/env sh

wob_script="$HOME/.config/hypr/scripts/wob.sh"

case "$1" in
    up)
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
        volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2*100}')
        "$wob_script" 33ccff 1e1e2e "$volume"
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2*100}')
        "$wob_script" 33ccff 1e1e2e "$volume"
        ;;
    toggle)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED"; then
            # 静音时使用红色
            "$wob_script" ff4757 1e1e2e 0
        else
            # 正常时使用蓝色
            volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2*100}')
            "$wob_script" 33ccff 1e1e2e "$volume"
        fi
        ;;
    mic-toggle)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
            notify-send "🎤 麦克风" "已静音" -t 1500
        else
            notify-send "🎤 麦克风" "已开启" -t 1500
        fi
        ;;
esac