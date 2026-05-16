#!/bin/bash

printf '=%.0s' {1..100}; echo
echo "正在运行 download_by_vedio_id.sh..."
echo

# 1. 检查是否有 VEDIO_ID 传参
if [ -z "$1" ]; then
    echo "错误: 缺少 VEDIO_ID 参数"
    exit 1
fi

VEDIO_ID="$1"

# 2. 加载配置文件
echo "正在加载个人信息配置文件..."

CONF_FILE="./personal_info.conf"

if [[ -f "$CONF_FILE" ]]; then
    source "$CONF_FILE"
else
    echo "错误：找不到配置文件 $CONF_FILE"
    exit 1
fi

if [[ -z "$COOKIE_FILE" ]]; then
    echo "错误：$CONF_FILE 中未配置 COOKIE_FILE"
    exit 1
fi

if [[ -z "$DOWNLOAD_PATH" ]]; then
    echo "错误：$CONF_FILE 中未配置 DOWNLOAD_PATH"
    exit 1
fi

# 3. 下载视频
echo "开始调用 yt-dlp 下载视频..."

mkdir -p "$DOWNLOAD_PATH"

# 检查视频是否已下载
if ls "$DOWNLOAD_PATH"/*"$VEDIO_ID"*.mp4 >/dev/null 2>&1; then
    echo "跳过：本地已存在包含 ID 为 $VEDIO_ID 的视频文件，无需下载。"
    exit 0
fi

yt-dlp --cookies "$COOKIE_FILE" \
       -f "best[format_id^=hls]" \
       --no-cache-dir \
       -o "$DOWNLOAD_PATH/$VEDIO_ID.mp4" \
       http://www.pornhub.com/view_video.php?viewkey="$VEDIO_ID"

if [[ $? -eq 0 ]]; then
    echo "视频下载成功！根据其 ID 命名为为 $VEDIO_ID.mp4。"
else
    echo "错误：视频下载失败！"
    exit 1
fi

echo
