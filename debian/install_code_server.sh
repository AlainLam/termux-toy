#!/usr/bin/env bash
# Author: https://www.alainlam.cn

# Include util.sh
# 引入基础脚本工具
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "$SCRIPT_PATH/../util/util.sh"

# Double confirm if package installation is required
# 重复确认是否需要安装软件包
if [ -d "$HOME/Applications/coder" ]; then
    echo2log "It seems that you have installed the Code Server, but you can continue with the reinstall. Therefore, just confirm again whether you want to continue?(Y/n): "
    read2log "您似乎已经安装了代码服务器，但可以继续重新安装。因此，只是再次确认是否要继续？(Y/n): " is_continue_reinstall
    while [[ "$is_continue_reinstall" != "Y" && "$is_continue_reinstall" != "y" && "$is_continue_reinstall" != "N" && "$is_continue_reinstall" != "n" ]]; do
        echo2log "Please input a valid values(Y/n): "
        read2log "请输入有效值(Y/n): " is_continue
    done
    if [[ "$is_continue_reinstall" == "N" || "$is_continue_reinstall" == "n" ]];then
        exit
    fi
fi

# Update the apt source
# 更新软件源
exec_prompt "sudo apt update"

# Create download directory
# 创建下载目录
exec_prompt 'mkdir -p $HOME/Downloads'
exec_prompt 'cd $HOME/Downloads'

# Downloading the Code Server
# 下载Code Server
echo2log "Debian ENV: Downloading the Code Server"
echo2log "Debian ENV: 下载Code Server"

exec_prompt 'curl -OJL --progress-bar https://github.com/coder/code-server/releases/download/v4.17.1/code-server-4.17.1-linux-arm64.tar.gz'

# Decompress
# 解压缩
exec_prompt 'mkdir -p ./coder.tmp'
exec_prompt 'tar -xvf code-server-*.tar.gz -C ./coder.tmp/'

# Create the Applications folder
# 创建存放应用程序的目录，如果不存在的话
if [ ! -d "$HOME/Applications" ]; then
    exec_prompt 'mkdir -p $HOME/Applications'
fi

# Move the cmdline tools to the target directory
# 移动到指定目录
mv ./coder.tmp/* "$HOME/Applications/coder"
rm -rf ./coder.tmp

# Setup the password for code server
# 设置code server的密码
code_server_pwd=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
echo2log "The code-server is already installed, 
and automatically generated random password.
Do you want to update your code-server password?
Enter a new password(Default is $code_server_pwd)"
read -r -p "Code Server已经安装完成, 并生成了随机密码.
你是否想要更新你的Code Server的密码?
请输入新的密码(默认是$code_server_pwd): " new_server_pwd
if [ -n "$new_server_pwd" ]; then
    code_server_pwd=$new_server_pwd
fi

# Update code-server port
# 更新Code Server的端口
code_server_port="8080"
echo2log "Do you want to update your code-server port?
Enter a new port(Default is $code_server_port): "
read -r -p "你是否想要更新你的Code Server监听的端口号？
请输入新的端口(默认是$code_server_port): " new_server_port

if [ -n "$new_server_port" ]; then
    code_server_port=$new_server_port
fi

# The configuration for code server
# 代码服务器的配置文
code_server_config="bind-addr: 127.0.0.1:$code_server_port
auth: password
password: $code_server_pwd
cert: false"

# Rewrite the server config.yaml
# 重写code server的配置文件
if [ ! -d "$HOME/.config/code-server" ]; then
    mkdir -p "$HOME/.config/code-server"
fi
echo2log "$code_server_config" >"$HOME/.config/code-server/config.yaml"
