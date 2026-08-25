#!/bin/bash
# ==============================================================================
# 脚本名称: build_ulauncher.sh
# 适用环境: Ubuntu 20.04 纯净环境 / Docker 容器内
# 脚本功能: 离线提取并构建一个完全属于用户态、免 root、解压即用的 Ulauncher 超级大礼包
# ==============================================================================

# 一旦任何一行命令执行出错，立刻终止脚本，防止带病打包
set -e

echo "=========================================================="
echo "🚀 开始构建 Ulauncher 20.04 用户态全能离线便携包..."
echo "=========================================================="

# 1. 确保环境处于非交互模式，锁死时区防止弹窗挂起
export DEBIAN_FRONTEND=noninteractive
if [ -f /usr/share/zoneinfo/Etc/UTC ]; then
    ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime
fi

# 2. 安装管理 PPA 和提取包所需的基础系统工具
echo "📦 步骤 1: 正在更新系统源并安装 APT 基础工具..."
apt-get update
apt-get install -y software-properties-common binutils curl

# 3. 注入 Ulauncher 官方针对 Ubuntu 20.04 (Focal) 的 PPA 仓库
echo "🌐 步骤 2: 正在添加 Ulauncher 官方 PPA 软件源..."
add-apt-repository -y ppa:agornostal/ulauncher
apt-get update

# 4. 创建隔离的输出便携目录结构
echo "📁 步骤 3: 正在初始化用户态隔离目录结构..."
OUTPUT_DIR="ulauncher-portable"
mkdir -p "$OUTPUT_DIR/lib/girepository-1.0"
mkdir -p "$OUTPUT_DIR/bin"

# 5. 建立临时下载与解压工作区
DOWNLOAD_DIR="deb-downloads"
EXTRACT_DIR="tmp-extract"
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$EXTRACT_DIR"

cd "$DOWNLOAD_DIR"

# 6. 精准且完整地下载 Ulauncher 及其所有被你提及的深层图形/网络依赖
echo "📥 步骤 4: 正在顺着依赖链离线抓取所有的 .deb 实体安装包..."
apt-get download ulauncher \
          gir1.2-keybinder-3.0 libkeybinder-3.0-0 \
          gir1.2-webkit2-4.0 libwebkit2gtk-4.0-37 \
          gir1.2-javascriptcoregtk-4.0 gir1.2-soup-2.4 \
          libicu66 libwebp6 libmanette-0.2-0 

cd ..

# 11. 清理临时工件并打包输出
echo "🧹 步骤 9: 正在进行末尾垃圾清理并压缩存盘..."
tar -czvf ulauncher-ubuntu20-portable.tar.gz  "$DOWLOAD_DIR/"

rm -rf "$DOWNLOAD_DIR" "$EXTRACT_DIR"


echo "=========================================================="
echo "🎉 恭喜！全功能内网离线包构建成功！"
echo "产物文件: $(pwd)/ulauncher-ubuntu20-portable.tar.gz"
echo "=========================================================="