#!/usr/bin/env sh

wob_pipe="$HOME/.cache/wob_pipe"
ini="$HOME/.config/wob/wob.ini"

# 创建配置目录
mkdir -p "$(dirname "$ini")"

# 创建命名管道
[ -p "$wob_pipe" ] || mkfifo "$wob_pipe"

# 颜色参数
color="${1:-33ccff}"
bg_color="${2:-1e1e2e}"
value="${3:-}"

# 强制重新创建配置并重启 wob
pkill -x wob 2>/dev/null

cat > "$ini" <<EOF
timeout = 1500
max = 100
width = 300
height = 30
border_offset = 2
border_size = 2
bar_padding = 2
anchor = top center
margin = 20
overflow_mode = wrap
border_color = $color
bar_color = $color
background_color = $bg_color
EOF

# 启动新的 wob 实例
tail -f "$wob_pipe" | wob --config "$ini" &

# 等待 wob 启动
sleep 0.1

# 发送数值
if [ -n "$value" ]; then
    echo "$value" > "$wob_pipe"
fi