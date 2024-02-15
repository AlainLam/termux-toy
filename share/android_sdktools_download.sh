#!/usr/bin/env bash
# Author: https://www.alainlam.cn

# Include util.sh
# 引入基础脚本工具
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "$SCRIPT_PATH/../util/util.sh"

# Get the compiled tools
# 下载编译好的工具
if [ ! -d "$HOME/Android/android-sdk-tools" ]; then
    curl -OJL --progress-bar https://github.com/lzhiyong/android-sdk-tools/releases/download/34.0.3/android-sdk-tools-static-aarch64.zip

    # Decompress
    # 解压缩
    unzip android-sdk-tools-static-aarch64.zip
    rm -rf android-sdk-tools-static-aarch64.zip

    # Move the tools
    # 移动工具到指定目录
    mkdir -p "$HOME/Android/android-sdk-tools"
    mv platform-tools "$HOME/Android/android-sdk-tools/"
    mv build-tools "$HOME/Android/android-sdk-tools/"
fi

# Set up the environment
# 设置环境变量
if ! grep -q 'export PATH="$PATH:$HOME/Android/android-sdk-tools/platform-tools/"' "$HOME/.profile"; then
    echo2log 'export PATH="$PATH:$HOME/Android/android-sdk-tools/platform-tools/"' >> "$HOME/.profile"
    source "$HOME/.profile"
fi