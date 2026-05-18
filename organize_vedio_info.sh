#!/bin/bash

printf '=%.0s' {1..100}; echo
echo "正在运行 organize_vedio_info.sh..."
echo

# 1. 检查配置文件
echo "正在加载个人信息配置文件..."

CONF_FILE="./personal_info.conf"

if [[ -f "$CONF_FILE" ]]; then
    source "$CONF_FILE"
else
    echo "错误：找不到配置文件 $CONF_FILE"
    exit 1
fi

if [[ -z "$VEDIO_INFO_JSON" ]]; then
    echo "错误：$CONF_FILE 中未配置 VEDIO_INFO_JSON"
    exit 1
fi

# 2. 整理文件信息
echo "开始将视频信息整理到 JSON 文件..."

TEMP_FILE="${VEDIO_INFO_JSON}.tmp"

# 按标准格式写入并去重
echo "[" > "$TEMP_FILE"
sed -e '/^[[:space:]]*$/d' \
    -e '/^[[:space:]]*[][][[:space:]]*$/d' \
    -e 's/,[[:space:]]*$//' \
    "$VEDIO_INFO_JSON" | \
awk '!sub_lines[$0]++' | \
sed -e '$!s/$/,/' >> "$TEMP_FILE"
echo "]" >> "$TEMP_FILE"

mv "$TEMP_FILE" "$VEDIO_INFO_JSON"

echo "视频信息已整理到 JSON 文件"

echo
