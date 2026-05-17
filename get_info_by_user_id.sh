#!/bin/bash

printf '=%.0s' {1..100}; echo
echo "正在运行 get_info_by_user_id.sh..."
echo

# 1. 加载配置文件
echo "正在加载个人信息配置文件..."

CONF_FILE="./personal_info.conf"

if [[ -f "$CONF_FILE" ]]; then
    source "$CONF_FILE"
else
    echo "错误：找不到配置文件 $CONF_FILE"
    exit 1
fi

if [[ -z "$USER_ID" ]]; then
    echo "错误：$CONF_FILE 中未配置 USER_ID"
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

if [[ -z "$HUB_INFO_FILE" ]]; then
    echo "错误：$CONF_FILE 中未配置 HUB_INFO_FILE"
    exit 1
fi

# 2. 使用 yt-dlp 提取信息
echo "正在提取用户 [$USER_ID] 的收藏夹..."

yt-dlp --cookies "$COOKIE_FILE" \
       --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
       --flat-playlist \
       --print "%(id)s || %(title)s" \
       "https://cn.pornhub.com/users/$USER_ID/videos/favorites" \
       | tac > $HUB_INFO_FILE

# 3. 结果反馈
if [ -s "$HUB_INFO_FILE" ]; then
    echo "提取完成！共提取 $(wc -l < "$HUB_INFO_FILE") 个视频信息，已保存至 $HUB_INFO_FILE"
    echo "信息保存格式为：\"id || title\""
else
    echo "提取失败。"
fi

echo
