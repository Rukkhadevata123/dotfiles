#!/usr/bin/env sh

wob_script="$HOME/.config/hypr/scripts/wob.sh"

case "$1" in
    up)
        # 使用固定步长而不是百分比
        brightnessctl set +5%
        # 直接从 brightnessctl 输出中提取百分比
        percentage=$(brightnessctl | grep -oP '\(\K\d+(?=%\))')
        "$wob_script" f1c40f 1e1e2e "$percentage"
        ;;
    down)
        # 最小亮度保护
        current=$(brightnessctl get)
        max=$(brightnessctl max)
        if [ $((current * 100 / max)) -le 5 ]; then
            # 如果当前亮度 <= 5%，设置为 1%
            brightnessctl set 1%
        else
            brightnessctl set 5%-
        fi
        percentage=$(brightnessctl | grep -oP '\(\K\d+(?=%\))')
        "$wob_script" f1c40f 1e1e2e "$percentage"
        ;;
esac