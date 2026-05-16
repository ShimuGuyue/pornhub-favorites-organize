# PornHub Favorites Organizate

将 PornHub 收藏夹视频一键同步到本地。

## 功能

- 提取指定用户的 PornHub 收藏夹视频列表
- 批量下载收藏夹中的所有视频到本地
- 自动记录视频详情（id、作者、标题、时长），输出为 JSON
- 断点续传：已下载的视频自动跳过

## 依赖

- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- Bash 4.0+

## 快速开始

### 1. 配置

```bash
cp personal_info.conf.example personal_info.conf
```

编辑 `personal_info.conf`：

```bash
# PornHub 用户 ID（必填）
USER_ID="你的用户ID"

# yt-dlp 使用的 cookies 文件（必填）
COOKIE_FILE="./cookies.txt"

# 视频下载保存目录
DOWNLOAD_PATH="./vedio"

# 收藏夹信息保存文件
HUB_INFO_FILE=${DOWNLOAD_PATH}"/favorites.txt"

# 视频详情保存文件
VEDIO_INFO_FILE=${DOWNLOAD_PATH}"/vedio_info.json"
```

### 2. 准备 Cookies

将浏览器导出的 cookies 文件放到项目根目录，命名为 `cookies.txt`。

### 3. 运行

```bash
./sync_with_hub.sh
```

脚本会自动完成以下步骤：
1. 从 PornHub 获取你收藏夹中所有视频的 id 和标题
2. 逐个下载视频到 `vedio/` 目录
3. 整理视频信息为标准 JSON 格式

## 单独使用

也可以单独运行某个脚本：

```bash
# 仅获取收藏夹视频列表
./get_info_by_user_id.sh

# 下载指定视频
./download_by_vedio_id.sh <视频ID> <视频标题>

# 整理视频信息 JSON
./organize_vedio_info.sh
```

## 项目结构

```
.
├── sync_with_hub.sh              # 主入口：一键同步
├── get_info_by_user_id.sh        # 获取收藏夹视频列表
├── download_by_vedio_id.sh       # 下载单个视频
├── organize_vedio_info.sh        # 整理视频信息 JSON
├── personal_info.conf.example    # 配置文件模板
├── personal_info.conf            # 配置文件（不纳入版本控制）
├── cookies.txt                   # Cookies（不纳入版本控制）
└── vedio/
    ├── favorites.txt             # 收藏夹视频列表（id || title）
    └── vedio_info.json           # 视频详情（id、作者、标题、时长）
```

