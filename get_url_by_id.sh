#!/bin/bash

# --- 配置 ---
ID_FILE="user_id.txt"
COOKIE_FILE="cookies.txt"
OUTPUT_FILE="favorites.txt"

# 1. 从文件中读取 ID
if [[ ! -f "$ID_FILE" ]]; then
    echo "错误：找不到文件 $ID_FILE"
    exit 1
fi

USER_ID=$(head -n 1 "$ID_FILE" | tr -d '[:space:]')

echo "正在提取用户 [$USER_ID] 的收藏夹..."

# 2. 调用 yt-dlp 提取链接
yt-dlp --cookies "$COOKIE_FILE" \
       --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
       --flat-playlist \
       --print "%(id)s || %(title)s" \
       "https://cn.pornhub.com/users/$USER_ID/videos/favorites" \
       > "$OUTPUT_FILE"

# 3. 结果反馈
if [ -s "$OUTPUT_FILE" ]; then
    echo "提取完成！共提取 $(wc -l < "$OUTPUT_FILE") 个链接，已保存至 $OUTPUT_FILE"
else
    echo "提取失败。"
fi