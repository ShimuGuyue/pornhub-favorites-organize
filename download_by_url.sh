#!/bin/bash

# 1. 检查参数：如果没有输入 URL 则退出
if [ -z "$1" ]; then
    echo "Usage: phdl <URL>"
    exit 1
fi

# 2. 定位脚本所在目录
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
COOKIE_FILE="$SCRIPT_DIR/cookies.txt"
PROXY="http://127.0.0.1:10809"

# 3. 执行下载
yt-dlp --cookies "$COOKIE_FILE" \
       --proxy "$PROXY" \
       -f "best[format_id^=hls]" \
       --no-cache-dir \
       -o "$SCRIPT_DIR/%(uploader)s - %(title)s [%(id)s].%(ext)s" \
       "$1"