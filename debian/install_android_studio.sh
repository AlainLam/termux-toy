#!/usr/bin/env bash
# Author: https://www.alainlam.cn

# Include util.sh
# 引入基础脚本工具
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "$SCRIPT_PATH/../util/util.sh"

# Double confirm if package installation is required
# 重复确认是否需要安装软件包
if [ -d "$HOME/Android/android-studio" ]; then
    echo2log "It seems that you have installed the Android Studio, but you can continue with the reinstall. Therefore, just confirm again whether you want to continue?(Y/n): "
    read2log "您似乎已经安装了代码服务器，但可以继续重新安装。因此，只是再次确认是否要继续？(Y/n): " is_continue_reinstall
    while [[ "$is_continue_reinstall" != "Y" && "$is_continue_reinstall" != "y" && "$is_continue_reinstall" != "N" && "$is_continue_reinstall" != "n" ]]; do
        echo2log "Please input a valid values(Y/n): "
        read2log "请输入有效值(Y/n): " is_continue
    done
    if [[ "$is_continue_reinstall" == "N" || "$is_continue_reinstall" == "n" ]]; then
        exec_prompt 'exec "$SCRIPT_PATH/inlet.sh"'
    fi
fi

# Reference
# 引用
echo2log "Debian ENV: Please see also:"
echo2log "Debian ENV: https://github.com/termux/termux-packages/issues/8350"
echo2log "Debian ENV: https://github.com/lzhiyong/android-sdk-tools"
echo2log "Debian ENV: https://github.com/lzhiyong/android-sdk-tools/releases"

# Update the apt source
# 更新软件源
exec_prompt "sudo apt update"

# Install JDK 17
# 安装JDK 17
echo2log "Debian ENV: Installing openjdk-17-jre..."
exec_prompt 'sudo apt install openjdk-17-jre -y'

# Configure Android Environment Variables
# 配置Android环境变量
if grep -q "Android Environment Variables" "$HOME/.profile"; then
    echo2log "Android environment variables have been set"
    echo2log "Android环境变量已设置"
else
    echo2log "Debian ENV: Configure Android Environment Variables"
    exec_prompt 'echo2log "" >> $HOME/.profile'
    exec_prompt 'echo2log "# Android Environment Variables" >> $HOME/.profile'
    exec_prompt 'echo2log "export ANDROID_HOME=\$HOME/Android/Sdk" >> $HOME/.profile'
    exec_prompt 'echo2log "export ANDROID_SDK_HOME=\$ANDROID_HOME" >> $HOME/.profile'
    exec_prompt 'echo2log "export ANDROID_USER_HOME=\$HOME/.android" >> $HOME/.profile'
    exec_prompt 'echo2log "export ANDROID_EMULATOR_HOME=\$ANDROID_USER_HOME" >> $HOME/.profile'
    exec_prompt 'echo2log "export ANDROID_AVD_HOME=\$ANDROID_EMULATOR_HOME/avd/" >> $HOME/.profile'
    exec_prompt 'echo2log "export PATH=\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/tools/bin:\$ANDROID_HOME/platform-tools" >> $HOME/.profile'
    exec_prompt 'source $HOME/.profile'
fi

# Create download directory
# 创建下载目录
exec_prompt 'mkdir -p $HOME/Downloads'
exec_prompt 'cd $HOME/Downloads'

# Download Android SDK command line tools
# 下载Android SDK命令行工具
echo2log "Debian ENV: Downloading Android SDK command line tools"
echo2log "Debian ENV: 下载Android SDK命令行工具"
exec_prompt 'curl -OJL --progress-bar https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip'
# Decompress
# 解压缩
exec_prompt 'unzip commandlinetools-linux-*.zip && rm -rf commandlinetools-linux-*.zip'
# Move the cmdline tools to the target directory
# 移动到指定目录
echo2log "Debian ENV: Move the cmdline tools to the target directory"
echo2log "Debian ENV: 移动命令行工具到指定目录"
exec_prompt 'mkdir -p $ANDROID_SDK_HOME/cmdline-tools/latest'
exec_prompt 'mv $HOME/Downloads/cmdline-tools/* $ANDROID_SDK_HOME/cmdline-tools/latest/'

# Agree all the licenses
# 同意Android SDK的全部条款
echo2log "Debian ENV: Agree all the licenses"
echo2log "Debian ENV: 同意Android SDK的全部条款"
exec_prompt 'cd $ANDROID_SDK_HOME/cmdline-tools/latest/bin/'
exec_prompt 'yes | ./sdkmanager --licenses'

# Install the Emulator
# 安装模拟器
echo2log "Debian ENV: Fixing the issue of Android Studio missing an emulator that cannot run, but the emulator should be cannot works on the aarch64"
echo2log "Debian ENV: 修复Android Studio缺少一个无法运行的模拟器的问题，但模拟器应该是不能在aarch64上工作"
echo2log "Debian ENV: Downloading the Emulator..."
echo2log "Debian ENV: 下载模拟器..."
exec_prompt 'curl -OJL --progress-bar https://redirector.gvt1.com/edgedl/android/repository/emulator-linux_x64-10696886.zip'
# Decompress
# 解压缩
exec_prompt 'unzip emulator-linux_x64-*.zip && rm -rf emulator-linux_x64-*.zip'
# Move the emulator to the target directory
# 移动模拟器到指定目录
exec_prompt 'mv ./emulator $ANDROID_SDK_HOME/'
# Fix the package.xml
# 修复package.xml文件问题
exec_prompt 'cp "$PROJECT_DIR/debian/package.xml" "$ANDROID_SDK_HOME/emulator/package.xml"'

# Install Android Studio
# 安装Android Studio
exec_prompt 'cd $HOME/Downloads'
# Downloading the Android Studio
# 下载Android Studio
echo2log "Debian ENV: Downloading the Android Studio"
echo2log "Debian ENV: 下载Android Studio"
exec_prompt 'curl -OJL --progress-bar https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.3.1.20/android-studio-2022.3.1.20-linux.tar.gz'
# Decompress
# 解压缩
exec_prompt 'tar -xvf android-studio-*-linux.tar.gz && rm -rf android-studio-*-linux.tar.gz'
# Move the android-studio to the target directory
# 移动 android-studio 到指定目录
exec_prompt 'mv ./android-studio $HOME/Android/android-studio'

# Do you want to automatically fix the issue with the compilation(sdk tools) tool
# 是否要使用编译（sdk tools）工具自动修复此问题
# But there will be some performance loss, and some devices do not support inotify
# 存在一定的性能损失，并且某些设备不足以支持运行inotify
echo2log "Do you want to automatically fix the issue with the sdk tools"
echo2log "But there will be some performance loss, and some devices do not support inotify(Y/n): "
echo2log "是否自动修复SDK编译工具问题"
echo2log "但存在一定的性能损失，并且某些设备不足以支持运行inotify(Y/n): "
read -r is_autofix_sdktools
while [[ $is_autofix_sdktools != "Y" && $is_autofix_sdktools != "y" && $is_autofix_sdktools != "N" && $is_autofix_sdktools != "n" ]]; do
    echo2log "Do you want to automatically fix the issue with the sdk tools(Y/n): "
    read -r -p "是否自动修复编译工具问题(Y/n): " is_autofix_sdktools
done

if [ "$is_autofix_sdktools" != "Y" ] && [ "$is_autofix_sdktools" != "y" ]; then
    # Install inotify-tools
    # 安装inotify-tools
    echo2log "Debian ENV: Installing inotify-tools..."
    echo2log "Debian ENV: 安装inotify-tools"
    exec_prompt 'sudo apt install inotify-tools -y'

    # Running the debianX_android_sdktools.sh on the background
    # 自动运行
    exec_prompt 'touch /var/log/android_sdktools_autofix.log'
    exec_prompt 'echo2log "" >> $HOME/.profile'
    exec_prompt 'echo2log "# Running the android_sdktools_autofix.sh on the background" >> $HOME/.profile'
    exec_prompt 'echo2log "bash /tmp/termux-toy/debian/android_sdktools_autofix.sh >> /var/log/android_sdktools_autofix.log 2>&1 &" >> $HOME/.profile'
else
    is_download_sdktools=""
    while [[ $is_download_sdktools != "Y" && $is_download_sdktools != "y" && $is_download_sdktools != "N" && $is_download_sdktools != "n" ]]; do
        echo2log "Do you want to download the sdk tools to $HOME/Android/android-sdk-tools"
        read -r -p "是否下载编译工具到$HOME/Android/android-sdk-tools目录(Y/n): " is_download_sdktools
    done
    if [ "$is_download_sdktools" != "Y" ] && [ "$is_download_sdktools" != "y" ]; then
        # Get the compiled tools
        # 下载编译好的工具
        exec_prompt 'curl -OJL --progress-bar https://github.com/lzhiyong/android-sdk-tools/releases/download/34.0.3/android-sdk-tools-static-aarch64.zip'
        # Decompress
        # 解压缩
        exec_prompt 'unzip android-sdk-tools-static-aarch64.zip'
        exec_prompt 'rm -rf android-sdk-tools-static-aarch64.zip'
        # Move the tools
        # 移动工具到指定目录
        exec_prompt 'mkdir $HOME/Android/android-sdk-tools'
        exec_prompt 'mv platform-tools $HOME/Android/android-sdk-tools/'
        exec_prompt 'mv build-tools $HOME/Android/android-sdk-tools/'
    else
        echo2log "Because you haven't download the android sdk tools, so the Android Studio should not working on your end"
        echo2log "因为你没有下载SDK工具，所以Android Studio应该不能正常运行"
        echo2log "https://github.com/lzhiyong/android-sdk-tools/releases/download/34.0.3/android-sdk-tools-static-aarch64.zip"
    fi
fi
