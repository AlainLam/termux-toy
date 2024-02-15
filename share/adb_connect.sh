#!/usr/bin/env bash
# Author: https://www.alainlam.cn

# Include util.sh
# 引入基础脚本工具
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "$SCRIPT_PATH/../util/util.sh"

# Check if localhost is already connected
# 检查是否已经连接了localhost
is_connected=false
if ! $kill_adb; then
    if adb devices | grep -q "localhost"; then
        echo2log "ADB server running, and connected to localhost."
        echo2log "ADB Server正在运行，且已连接localhost"
        is_connected=true
    else
        echo2log "ADB server running, but not connected to localhost."
        echo2log "ADB Server正在运行，但未连接到localhost"
    fi
fi

# Show the title on menu
# 在菜单中显示标题
title() {
    if $is_connected; then
        echo "Disconnect ADB from localhost
    断开连接到localhost的ADB"
    else
        echo "Connect to localhost using ADB
    使用ADB连接到localhost"
    fi
}
source "$SCRIPT_PATH/../util/title.sh"

# Attempt to connect to the specified port range
# 尝试连接到指定端口范围
connect_to_ports() {
    local ports=("$@")
    local adb_output
    for port in "${ports[@]}"; do
        # Attempt connection
        # 尝试连接
        echo2log "adb connecting localhost:$port"
        exec_prompt 'adb_output=$(adb connect localhost:"$port" 2>&1)'
        # Check if connection is successful
        # 检查连接是否成功
        if [[ $adb_output =~ connected ]]; then
            echo2log "adb connected localhost:$port"
            # Save the port to the config file
            # 保存端口号
            if grep -q "^Android_ADB_Port=" "$CONFIGURATION_FILE"; then
                exec_prompt 'sed -i "s/^Android_ADB_Port=.*/Android_ADB_Port=$port/" "$CONFIGURATION_FILE"'
            else
                echo2log "Android_ADB_Port=$port" >>"$CONFIGURATION_FILE"
            fi
            back2home 0
        fi
    done
    echo2log "Failed to connect to any port"
    echo2log "无法连接到如何端口"
    back2home 1
}

# ADB tools are necessary
# ADB工具是必须的
if ! [ -x "$(command -v adb)" ]; then
    is_install_adb=""
    while [[ $is_install_adb != "Y" && $is_install_adb != "y" && $is_install_adb != "N" && $is_install_adb != "n" ]]; do
        echo2log "This feature requires the adb tool, do you want to install it?(Y/n): "
        read2log "这个功能需要安装adb，你是否想要安装它？(Y/n): " is_install_adb
    done
    if [ $is_install_adb == "Y" ] || [ $is_install_adb == "y" ]; then
        if [[ -n "$PREFIX" ]]; then
            echo2log "Currently in the Termux environment"
            echo2log "当前在 Termux 环境中"
            exec_prompt 'pkg install android-tools -y'
        else
            echo2log "Currently in the proof distro container"
            echo2log "当前在 proot-distro 容器中"
            exec_prompt 'bash $PROJECT_DIR/share/android_sdktools_download.sh'
            exec_prompt 'source $HOME/.profile'
        fi
    else
        back2home 1
    fi
fi

adb_method=""
while [[ $adb_method != "1" && $adb_method != "2" ]]; do
    read2log '
    1) Pair to localhost using ADB
       使用ADB配对到本地

    2) Connect to localhost using ADB
       使用ADB连接到本地
    ' adb_method
done

if [ $adb_method == "1" ]; then
    adb_port=""
    while [[ ! $adb_port =~ ^[0-9]+$ ]]; do
        echo2log "Please enter a valid port(1-65535): "
        read2log "请输入一个有效的端口(1-65535): " adb_port
    done
    exec_prompt 'adb pair localhost:$adb_port'
    back2home 0
else
    # Prompt about the input port method
    # 提示有关输入端口的方式
    echo2log "Do you want to automatically scan the port number or manually enter it? Automatic scanning will take a lot of time."
    echo2log "你想自动扫描端口号，还是手动输入？自动扫描将花费大量时间。"
    is_autoscan_port=""
    while [[ $is_autoscan_port != "1" && $is_autoscan_port != "2" ]]; do
        read2log "
    1) Auto scan - 自动扫描
    2) Manually input - 手动输入
    
    Please enter the 1 or 2: " is_autoscan_port
    done

    if [ "$is_autoscan_port" == "1" ]; then
        # If nmap is not installed, prompt it as necessary and prompt the user if they want to install it
        # 如果nmap没有安装，则提示它是必要的，并提示用户是否要安装它
        if ! [ -x "$(command -v nmap)" ]; then
            is_install_nmap=""
            while [[ $is_install_nmap != "Y" && $is_install_nmap != "y" && $is_install_nmap != "N" && $is_install_nmap != "n" ]]; do
                echo2log "This feature requires the nmap tool, do you want to install it?(Y/n): "
                read2log "这个功能需要安装nmap，你是否想要安装它？(Y/n): " is_install_nmap
            done
            if [ $is_install_nmap == "Y" ] || [ $is_install_nmap == "y" ]; then
                exec_prompt 'apt install nmap -y'
            else
                back2home 1
            fi
        fi

        # Get the saved port from the CONFIGURATION file
        # 从配置文件中获取以往保存的端口号
        exec_prompt 'adb_ports=$(grep "Android_ADB_Ports" "$CONFIGURATION_FILE" | cut -d "=" -f 2)'

        # Prompt if user want to update the ports range
        # 提示用户是否想要修改端口号
        if [ -n "$adb_ports" ]; then
            echo2log "Current pending ports range is: $adb_ports"
            echo2log "当前待扫描端口号范围是: $adb_ports"
            echo2log "Do you want to change your ports range?(Y/n, default to n): "
            read2log "你是否想要修改端口号？（Y/n，默认是n）" is_update_ports
            if [ -z "$is_update_ports" ]; then
                is_update_ports="n"
            fi
            while [[ $is_update_ports != "Y" && $is_update_ports != "y" && $is_update_ports != "N" && $is_update_ports != "n" ]]; do
                echo2log "Please enter a (Y|y|N|n):"
                read2log "请输入一个Y或y或N或n: " is_update_ports
            done
            if [[ $is_update_ports == "Y" || $is_update_ports == "y" ]]; then
                adb_ports=""
            fi
        fi

        # Verify the ports range
        # 检查ports范围
        while true; do
            if [[ $adb_ports =~ ^([0-9]+)-([0-9]+)$ ]]; then
                start_port=${BASH_REMATCH[1]}
                end_port=${BASH_REMATCH[2]}
                if ((start_port > end_port)); then
                    echo2log "The start port must be less than or equal to the end port."
                    echo2log "起始端口必须小于或等于结束端口。"
                else
                    break
                fi
            fi
            echo2log "Please enter a valid port range that you want to scan, for example: 30000-40000, please enter a port range: "
            read2log "请输入一个有效的端口范围，比如：30000-40000, 请输入端口范围: " adb_ports
        done

        # Save the adb_ports to the config file
        # 保存端口号
        if grep -q "^Android_ADB_Ports=" "$CONFIGURATION_FILE"; then
            exec_prompt 'sed -i "s/^Android_ADB_Ports=.*/Android_ADB_Ports=$adb_ports/" "$CONFIGURATION_FILE"'
        else
            echo2log "Android_ADB_Ports=$adb_ports" >>"$CONFIGURATION_FILE"
        fi

        # Scanning the port
        # 扫描端口
        echo2log "pending the localhost:$adb_ports"
        nmap_output=$(nmap -p "$adb_ports" localhost --unprivileged)
        while IFS= read -r line; do
            if [[ $line =~ ^[0-9]+/tcp.*open.* ]]; then
                echo2log "$line"
                port=$(echo "$line" | awk -F/ "{print $1}")
                adb_pending_ports+=("$port")
            fi
        done <<<"$nmap_output"

        # Attempt connection to ports
        # 尝试连接端口
        connect_to_ports "${adb_pending_ports[@]}"
    else
        adb_port=""
        while [[ ! $adb_port =~ ^[0-9]+$ ]]; do
            echo2log "Please enter a valid port(1-65535): "
            read2log "请输入一个有效的端口(1-65535): " adb_port
        done
        # Attempt connection to port
        # 尝试连接端口
        connect_to_ports "$adb_port"
    fi
fi
