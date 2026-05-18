#!/bin/bash

printf '=%.0s' {1..100}; echo
echo "正在运行 download_by_vedio_id.sh..."
echo

# 1. 检查参数传递
if [ -z "$1" ]; then
    echo "错误: 缺少视频 VEDIO_ID 参数"
    exit 1
fi

if [ -z "$2" ]; then
    echo "错误: 缺少重命名 TITLE 参数"
    exit 1
fi

VEDIO_ID="$1"
RENAME_TITLE="$2"

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

if [[ -z "$VEDIO_INFO_FILE" ]]; then
    echo "错误：$CONF_FILE 中未配置 VEDIO_INFO_FILE"
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

# 记录视频信息
yt-dlp --cookies "$COOKIE_FILE" \
       --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
       --print "{\"id\": \"%(id)s\", \"作者\": \"%(uploader)s\", \"标题\": \"$RENAME_TITLE\", \"时长\": \"%(duration_string)s\"}" \
       "http://cn.pornhub.com/view_video.php?viewkey=$VEDIO_ID" \
        >> "$VEDIO_INFO_FILE" 2>/dev/null

# 下载视频
yt-dlp --cookies "$COOKIE_FILE" \
       --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
       -f "bestvideo+bestaudio/best" \
       --no-cache-dir \
       --parse-metadata "$RENAME_TITLE:%(rename_title)s" \
       -o "$DOWNLOAD_PATH/[%(id)s] [%(uploader)s] [%(rename_title)s] [%(duration_string)s].mp4" \
       "http://cn.pornhub.com/view_video.php?viewkey=$VEDIO_ID"

if [[ $? -eq 0 ]]; then
    echo "视频下载成功！"
else
    echo "错误：视频下载失败！"
    exit 1
fi

echo
