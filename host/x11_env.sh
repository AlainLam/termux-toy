#!/usr/bin/env bash
# Author: https://www.alainlam.cn

# Include util.sh
# 引入基础脚本工具
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "$SCRIPT_PATH/../util/util.sh"

# Show the title on menu
# 在菜单中显示标题
title() {
    echo "Install X11 environment
    安装X11环境"
}
source "$SCRIPT_PATH/../util/title.sh"

# This feature requires storage permissions
# 这个功能需要存储权限
storage_requires() {
    touch "$HOME/storage/downloads/.termux-toy"
    if [ $? -ne 0 ]; then
        is_continue_storage=""
        while [[ $is_continue_storage != "Y" && $is_continue_storage != "y" && $is_continue_storage != "N" && $is_continue_storage != "n" ]]; do
            echo2log "This feature requires storage permissions to download the target APKs to your Downloads directory, do you want to continue? (Y/n): "
            read2log "这个功能需要存储权限来下载指定的apk到你的下载目录，你想要继续吗？(Y/n): " is_continue_storage
        done
        if [[ "$is_continue_storage" == "Y" || "$is_continue_storage" == "y" ]]; then
            termux-setup-storage
        fi
        echo2log ""
        echo2log "Because can not confirm if you already have permission, please select the option you want to install again"
        echo2log "由于无法确认您是否已经拥有权限，请选择要重新安装的选项"
        return 1
    else
        rm -rf "$HOME/storage/downloads/.termux-toy"
        return 0
    fi
}

# Directly download and install on some devices is not available, so add an option to open a webpage
# 直接下载并安装在一些设备并不可用,所以提供了打开网页的选项
download_options() {
    local option=""
    local label="$1"
    local varname="$2"
    while [[ $option != "1" && $option != "2" ]]; do
        echo2log "1) Download and install $label directly, but may not be successful"
        echo2log "   直接下载并安装$label，但是可能无法成功"
        echo2log "2) Open the download link on browser"
        echo2log "   从浏览器打开下载链接"
        echo2log ""
        echo2log "Please select a option you want(1/2):"
        read2log "请选择一个你想要的选项(1/2, default is 2): " option
        if [ -z $option ]; then
            option="2"
        fi
    done
    printf -v "$varname" '%s' "$option"
}

echo2log "Install X11 environment"
echo2log "安装X11环境"
# Install the x11-repo root-repo
# 安装x11-repo root-repo软件库
echo2log "Install the x11-repo root-repo"
echo2log "安装x11-repo root-repo软件库"
exec_prompt 'pkg install x11-repo root-repo -y'
# Set up the Desktop Environment
# 配置桌面环境
exec_prompt 'pkg install termux-x11-nightly pulseaudio virglrenderer-android -y'
# Install the proot-distro
# 安装proot-distro
exec_prompt 'pkg install proot-distro -y'
# Update the package to latest
# 更新全部软件到最新
echo2log "Do you want to upgrade all packages?(Y/n): "
read2log "你想升级全部软件包吗？(Y/n): " is_pkg_upgrade
if [[ "$is_pkg_upgrade" == "Y" || "$is_pkg_upgrade" == "y" ]]; then
    echo2log "Update the package"
    echo2log "更新全部软件到最新"
    exec_prompt 'pkg upgrade -y'
fi

# Install the requires apks
# 安装必要的软件
while true; do
    # Read user input
    # 读取用户输入
    read2log '
  1) Install Termux:X11
     安装Termux:X11软件

  2) Install Termux:API
     安装Termux:API软件

  3) Install Termux:Widget
     安装Termux:Widget软件
  
  4) Back to home menu
     返回主菜单
    ' apk_option
    # This feature requires storage permissions
    # 这个功能需要存储权限
    if ! storage_requires; then
        continue
    fi
    case $apk_option in
    1)
        download_options "Termux:X11" x11_install_option
        if [[ $x11_install_option == "1" ]]; then
            exec_prompt 'cd "$HOME/storage/downloads/" || exit'
            if [ -f "app-armeabi-v7a-debug.apk" ]; then
                echo2log "Do you want to redownload the apk?(Y/n): "
                read2log "你想重新下载apk吗？(Y/n): " is_redownload_apk
                if [[ $is_redownload_apk == "Y" || $is_redownload_apk == "y" ]]; then
                    rm -rf "app-armeabi-v7a-debug.apk"
                fi
            fi
            if [ ! -f "app-armeabi-v7a-debug.apk" ]; then
                exec_prompt 'curl -SOL --progress-bar https://github.com/termux/termux-x11/releases/download/nightly/app-armeabi-v7a-debug.apk'
            fi
            exec_prompt 'termux-open app-armeabi-v7a-debug.apk'
            exec_prompt 'cd -'
        else
            exec_prompt 'termux-open-url "https://github.com/termux/termux-x11/releases"'
        fi
        ;;
    2)
        download_options "Termux:x11" is_installed_api
        if [[ $is_installed_api == "1" ]]; then
            exec_prompt 'cd "$HOME/storage/downloads/" || exit'
            if [ -f "com.termux.api_51.apk" ]; then
                echo2log "Do you want to redownload the apk?(Y/n): "
                read2log "你想重新下载apk吗？(Y/n): " is_redownload_apk
                if [[ $is_redownload_apk == "Y" || $is_redownload_apk == "y" ]]; then
                    rm -rf "com.termux.api_51.apk"
                fi
            fi
            if [ ! -f "com.termux.api_51.apk" ]; then
                exec_prompt 'curl -SOL --progress-bar https://f-droid.org/repo/com.termux.api_51.apk'
            fi
            exec_prompt 'termux-open com.termux.api_51.apk'
            exec_prompt 'cd -'
        else
            exec_prompt 'termux-open-url "https://f-droid.org/en/packages/com.termux.api/"'
        fi
        ;;
    3)
        download_options "Termux:Widget" is_installed_widget
        if [[ $is_installed_widget == "1" ]]; then
            exec_prompt 'cd "$HOME/storage/downloads/" || exit'
            if [ -f "com.termux.widget_13.apk" ]; then
                echo2log "Do you want to redownload the apk?(Y/n): "
                read2log "你想重新下载apk吗？(Y/n): " is_redownload_apk
                if [[ $is_redownload_apk == "Y" || $is_redownload_apk == "y" ]]; then
                    rm -rf "com.termux.widget_13.apk"
                fi
            fi
            if [ ! -f "com.termux.widget_13.apk" ]; then
                exec_prompt 'curl -SOL --progress-bar https://f-droid.org/repo/com.termux.widget_13.apk'
            fi
            exec_prompt 'termux-open com.termux.widget_13.apk'
            exec_prompt 'cd -'
        else
            exec_prompt 'termux-open-url "https://f-droid.org/en/packages/com.termux.widget/"'
        fi
        ;;
    *)
        exec_prompt 'exec "$PROJECT_DIR/menu.sh"'
        break
        ;;
    esac
done
