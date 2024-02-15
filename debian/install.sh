#!/usr/bin/env bash
# Author: https://www.alainlam.cn

# Include util.sh
# 引入基础脚本工具
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "$SCRIPT_PATH/../util/util.sh"

# Update the apt source
# 更新软件源
exec_prompt "apt update"

# Fixing garbled characters
# 修复乱码
# reference: https://wiki.archlinuxcn.org/wiki/Locale
exec_prompt 'apt install locales fonts-noto-cjk -y'
exec_prompt 'dpkg-reconfigure locales && locale'

# Update the package to latest
# 更新软件包到最新
echo2log "Debian ENV: Updating the package to latest"
echo2log "Debian ENV: 更新全部软件包到最新"
exec_prompt "apt dist-upgrade -y"

# Setup timezone
# 设置时区
tz=""
exec_prompt 'tz=$(tzselect) && ln -sf /usr/share/zoneinfo/$tz /etc/localtime'
echo2log "Update the timezone to: $tz"
echo2log "更新时区为$tz"

# Update the package to latest
# 更新软件包到最新
echo2log "Debian ENV: Install some necessary software"
echo2log "Debian ENV: 安装一些必要的软件"
exec_prompt "apt-get install sudo nano firefox-esr p7zip-full -y"

# Create a normal user
# 创建一个普通用户
echo2log "Debian ENV: Please create a normal user so that you can use it to login to xfce4 env"
echo2log "Debian ENV: 创建一个用户，你可以用它来登录你的桌面环境"
echo2log "Debian ENV: Please enter your username:"
echo2log "Debian ENV: 请输入你的用户名"

read -r normal_user_name
while [[ -z $normal_user_name ]]; do
    echo2log "Debian ENV: username can not be empty, please enter your username: "
    read2log "Debian ENV: 用户名不能为空, 请输入你的用户名: " normal_user_name
done
exec_prompt "adduser $normal_user_name"

# Grant the user sudo privileges.
# 赋予sudo权限
echo2log "Debian ENV: Grant $normal_user_name sudo privileges"
echo2log "Debian ENV: 赋予 $normal_user_name sudo 权限"
exec_prompt 'sed -i "/^root\s*ALL=(ALL:ALL)\s*ALL$/a $normal_user_name   ALL=(ALL:ALL) ALL" /etc/sudoers'

# Add user to video and audio groups.
# 添加到视频、音频用户组
echo2log "Debian ENV: Add $normal_user_name to video and audio groups"
echo2log "Debian ENV: 添加 $normal_user_name 到音视频用户组"
exec_prompt 'usermod -aG audio,video $normal_user_name'

# Install the xfce4
# 安装xfce桌面环境
echo2log "Debian ENV: Installing the xfce4 and xfce4-goodies"
exec_prompt 'apt install xfce4 xfce4-goodies -y'

# Install the input method
# 安装输入法
echo2log "Debian ENV: Installing the input method"
exec_prompt 'apt install fcitx5* -y'