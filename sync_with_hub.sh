#!/bin/bash

printf '=%.0s' {1..100}; echo
echo "正在运行 sync_with_hub.sh..."
echo

# 1. 检查配置文件
echo "1. 正在加载个人信息配置文件..."

CONF_FILE="./personal_info.conf"

if [[ -f "$CONF_FILE" ]]; then
    source "$CONF_FILE"
else
    echo "错误：找不到配置文件 $CONF_FILE"
    exit 1
fi

if [[ -z "$HUB_INFO_FILE" ]]; then
    echo "错误：$CONF_FILE 中未配置 HUB_INFO_FILE"
    exit 1
fi

# 2. 获取 pornhub 视频信息
echo "2. 正在获取 pornhub 收藏夹视频信息..."
"./get_info_by_user_id.sh"

# 3. 下载视频
echo "3. 开始批量下载收藏夹视频..."
echo

FAILED_IDS=""

while IFS= read -r line || [[ -n "$line" ]]; do
    VIDEO_ID=$(echo "$line" | awk -F ' \\|\\| ' '{print $1}' | tr -d '[:space:]')
    VIDEO_TITLE=$(echo "$line" | awk -F ' \\|\\| ' '{print $2}')

    echo "正在处理 ID: $VIDEO_ID"
    echo "视频标题: $VIDEO_TITLE"

    # 执行下载脚本
    "./download_by_vedio_id.sh" "$VIDEO_ID" "$VIDEO_TITLE"

    [[ $? -ne 0 ]] && FAILED_IDS+="$VIDEO_ID "
done < "$HUB_INFO_FILE"

echo "所有任务处理完毕！"

if [[ -n "$FAILED_IDS" ]]; then
    echo "以下 ID 视频下载失败: $FAILED_IDS"
else
    echo "所有视频下载成功！"
fi

# 4. 整理信息
echo "4. 开始整理视频信息..."

# 执行整理脚本
"./organize_vedio_info.sh"

echo "视频信息整理完成"
echo

# 5. 输出信息
echo "完成：pornhub favorites 页面视频已同步到本地。"
