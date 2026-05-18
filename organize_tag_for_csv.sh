#!/bin/bash

printf '=%.0s' {1..100}; echo
echo "正在运行 organize_tag_for_csv.sh ..."
echo

# 1. 加载配置文件
CONF_FILE="./personal_info.conf"

if [[ -f "$CONF_FILE" ]]; then
    source "$CONF_FILE"
else
    echo "错误：找不到配置文件 $CONF_FILE"
    exit 1
fi

if [[ ! -f "$VEDIO_INFO_CSV" ]]; then
    echo "错误：$CONF_FILE 中未配置 VEDIO_INFO_CSV"
    exit 1
fi

if [[ ! -f "$TAG_FILE" ]]; then
    echo "错误：$CONF_FILE 中未配置 TAG_FILE"
    exit 1
fi

OUTPUT_CSV="${VEDIO_INFO_CSV}.tmp"

# 2. 提取标签信息并排序去重
echo "正在获取全部标签..."

awk -v FPAT='([^,]*)|("[^"]+")' '
NR == 1 {
    for (i = 1; i <= NF; i++) {
        clean_header = $i
        gsub(/^\xEF\xBB\xBF/, "", clean_header)
        gsub(/["\r]/, "", clean_header)
        if (clean_header == "标签") {
            tag_col = i
            break
        }
    }
    next
}
{
    if (tag_col > 0 && $(tag_col) != "") {
        tag_str = $(tag_col)
        gsub(/[\r]/, "", tag_str)
        gsub(/^"|"$/, "", tag_str)
        if (tag_str != "")
            print tag_str
    }
}
' "$VEDIO_INFO_CSV" | tr ',' '\n' | sed '/^$/d' | sort -u > "$TAG_FILE"

echo "所有标签已完成汇总，存储于 $TAG_FILE"
echo "--- 标签预览 ---"
cat "$TAG_FILE"
echo

# 3. 根据汇总标签对 CSV 数据进行排序
echo "正在根据汇总标签对 CSV 数据进行排序..."

awk -v FPAT='([^,]*)|("[^"]+")' -v OFS=',' -v tag_list_file="$TAG_FILE" '
BEGIN {
    idx = 0
    while ((getline line < tag_list_file) > 0) {
        if (line != "") {
            idx++
            tag_order[line] = idx
        }
    }
    close(tag_list_file)
}

NR == 1 {
    for (i = 1; i <= NF; i++) {
        clean_header = $i
        gsub(/^\xEF\xBB\xBF/, "", clean_header)
        gsub(/["\r]/, "", clean_header)
        if (clean_header == "标签") {
            tag_col = i
            break
        }
    }
    print $0
    next
}

{
    if (tag_col > 0 && $(tag_col) != "") {
        tag_str = $(tag_col)

        gsub(/[\r]/, "", tag_str)
        gsub(/^"|"$/, "", tag_str)

        split(tag_str, raw_tags, ",")

        delete unique_tags
        for (j in raw_tags)
            if (raw_tags[j] != "")
                unique_tags[raw_tags[j]] = 1

        delete k_arr
        n = 0
        for (k in unique_tags)
            k_arr[++n] = k

        for (m = 1; m <= n; m++) {
            for (p = m + 1; p <= n; p++) {
                if (tag_order[k_arr[m]] > tag_order[k_arr[p]]) {
                    tmp = k_arr[m]
                    k_arr[m] = k_arr[p]
                    k_arr[p] = tmp
                }
            }
        }

        new_tag_str = ""
        for (m = 1; m <= n; m++)
            new_tag_str = (m == 1) ? k_arr[m] : new_tag_str "," k_arr[m]

        if (new_tag_str != "")
            $(tag_col) = "\"" new_tag_str "\""
        else
            $(tag_col) = ""
    }
    print $0
}
' "$VEDIO_INFO_CSV" > "$OUTPUT_CSV"

mv $OUTPUT_CSV $VEDIO_INFO_CSV

echo "CSV 文件内标签已排序完成"

echo
