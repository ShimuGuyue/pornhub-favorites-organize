#!/bin/bash

printf '=%.0s' {1..100}; echo
echo "正在运行 json_to_csv.sh..."
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

if [[ -z "$VEDIO_INFO_JSON" ]]; then
    echo "错误：$CONF_FILE 中未配置 VEDIO_INFO_JSON"
    exit 1
fi

VEDIO_INFO_CSV="${VEDIO_INFO_JSON%.json}.csv"

# 2. 将 json 文件转换为 CSV 格式
# 如果 CSV 文件不存在，全量写入；否则增量写入
echo "正在将 JSON 文件转换为 CSV 文件..."

if [[ ! -f "$VEDIO_INFO_CSV" ]]; then
    echo "未检测到历史 CSV 文件，正在全新创建..."

    printf '\xEF\xBB\xBFid,作者,标题,时长,标签\n' > "$VEDIO_INFO_CSV"

    jq -r '.[] |
        "[\(.id)]," +
        "\(."作者" | split(",") | join("，"))," +
        "\(."标题" | split(",") | join("，"))," +
        "\(."时长"),"' \
        "$VEDIO_INFO_JSON" | while LC_ALL=C read -r row
    do
        id=$(echo "$row" | cut -d',' -f1 | tr -d '"[]')
        if [[ -n "$id" ]]; then
            echo "写入: [ID: $id]"
            echo "$row" >> "$VEDIO_INFO_CSV"
        fi
    done
else
    echo "检测到已有历史 CSV 文件，正在增量写入..."

    jq -r '.[] |
        "[\(.id)]," +
        "\(."作者" | split(",") | join("，"))," +
        "\(."标题" | split(",") | join("，"))," +
        "\(."时长"),"' \
        "$VEDIO_INFO_JSON" | while LC_ALL=C read -r row
    do
        id=$(echo "$row" | cut -d',' -f1 | tr -d '"[]')
        if [[ -n "$id" ]]; then
            id_match="^\"?\[${id}\]"

            if grep -E -q "$id_match" "$VEDIO_INFO_CSV"; then
                echo "跳过: [ID: $id] 相关数据已存在"
            else
                echo "写入: [ID: $id] 是新数据，已追加至末尾"
                echo "$row" >> "$VEDIO_INFO_CSV"
            fi
        fi
    done
fi

echo "转换完成！结果已保存至 $VEDIO_INFO_CSV"

echo
