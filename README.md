# Pornhub Favorites Organizate

将 Pornhub 收藏夹视频在本地一键整理。

## 功能

- 提取指定用户的 PornHub 收藏夹视频列表
- 批量下载收藏夹中的所有视频到本地
- 自动记录视频详情（id、作者、标题、时长），输出为 JSON 和 CSV
- 根据用户在 CSV 中手动添加的标签进行汇总和排序

## 依赖

- yt-dlp

## 快速开始

### 1. 配置

按照 `personal_info.conf.example` 的格式创建 `personal_info.conf`：

```bash
# 私人数据，必须指定
## pornhub 用户 ID
USER_ID="xxxxxxx"
## 要使用的 cookies 文件路径
COOKIE_FILE="./cookies.txt"

# 输出信息，可使用默认值
## 视频下载保存目录
DOWNLOAD_PATH="./vedio"
## 收藏夹信息保存文件
HUB_INFO_FILE=${DOWNLOAD_PATH}"/favorites.txt"
## 视频信息保存文件
VEDIO_INFO_JSON=${DOWNLOAD_PATH}"/vedio_info.json"
VEDIO_INFO_CSV=${DOWNLOAD_PATH}"/vedio_info.csv"
TAG_FILE=${DOWNLOAD_PATH}"/tag.txt"
```

### 2. 运行

#### 1. 视频下载

```bash
./sync_with_hub.sh
```

脚本会自动完成以下步骤：
1. 从 PornHub 获取你收藏夹中所有视频的 id 和标题
2. 逐个下载视频到指定目录
3. 整理视频信息为标准 JSON 格式和 CSV 文件

#### 2. 标签整理

首先在 CSV 文件中为一些视频手动添加个性化标签（用 `,` 分割多个标签）

```cpp
./organize_tag_for_csv.sh
```

脚本会自动完成以下步骤：

1.   从 CSV 文件获取所有标签信息并排序去重后保存到指定文件
1.   根据文件中的汇总信息对 CSV 中标签进行排序

## 单独使用

也可以单独运行某个脚本：

```bash
# 获取收藏夹视频列表
./get_info_by_user_id.sh

# 下载指定视频并重命名（不可缺省）
./download_by_vedio_id.sh <视频ID> <视频标题>

# 将 JSON 文件中信息进行标准化
./organize_vedio_info.sh

# 将 JSON 文件转化为 CSV 文件
./json_to_csv.sh
```

## 项目结构

```
.
├── sync_with_hub.sh              # 主入口 1：一键整理收藏夹视频信息并下载视频
├── organize_tag_for_csv.sh       # 主入口 2：一键整理 CSV 文件中标签信息
├── get_info_by_user_id.sh        # 获取收藏夹视频列表
├── download_by_vedio_id.sh       # 下载单个视频
├── organize_vedio_info.sh        # 整理视频信息 JSON 和 CSV
├── personal_info.conf.example    # 配置文件模板
└── vedio/
    ├── favorites.txt             # 收藏夹视频列表（id || title）
    ├── vedio_info.json           # 视频详情（id、作者、标题、时长）
    ├── vedio_info.csv            # 视频详情（id、作者、标题、时长、标签）
    └── tags.txt                  # CSV 文件标签汇总
```