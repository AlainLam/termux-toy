#!/usr/bin/env bash
# Author: https://www.alainlam.cn

# Include util.sh
# 引入基础脚本工具
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "$SCRIPT_PATH/../util/util.sh"

# Determine whether max_phantom_processes is for rollback or fix
# 判断max_phantom_processes是回滚还是修复
is_rollback=false
if grep -q "old_max_phantom_processes" "$CONFIGURATION_FILE"; then
    is_rollback=true
else
    is_rollback=false
fi

# Show the title on menu
# 在菜单中显示标题
title() {
    if $is_rollback; then
        echo "Rollback max_phantom_processes to default
    回滚max_phantom_processes为默认值"
    else
        echo "Modify max_phantom_processes to max
    修改max_phantom_processes到最大值"
    fi
}
source "$SCRIPT_PATH/../util/title.sh"

# Prompts why we need to modify max_phantom_processes.
# 提示为什么需要修改max_phantom_processes
if ! $is_rollback; then
    echo2log "Since Android 12, the system has imposed limitations on the number of processes for each application. Typically, the parent process can only launch a maximum of 32 child processes. Therefore, when using Termux and installing a desktop environment, it is easy to exceed this limit, resulting in application crashes. Therefore, we need to modify this restriction."
    echo2log "因为Android12之后，系统会对每个应用的进程数进行限制，一般父进程最多只能启动32个子进程，所以当我们在使用termux并安装桌面环境的时候，很容易超过这个限制从而导致应用崩溃，所以我们需要将该限制进行修改。"
fi

# If the adb server was started by the current script, it needs to be killed.
# 如果adb server由当前脚本启动时，则需要终止adb server
kill_adb=false
if ! pgrep -x "adb" >/dev/null; then
    exec_prompt 'adb start-server'
    kill_adb=true
fi

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

# If not yet connected to localhost, attempt to connect
# 如果还没有连接到localhost，则尝试连接
disconnect_adb=false
if ! $is_connected; then
    exec_prompt 'bash $PROJECT_DIR/share/adb_connect.sh'
    exec_prompt 'source $HOME/.profile'
    is_connected=true
    disconnect_adb=true
fi

# If the connection is successful, fix max_phantom_processes
# 如果连接成功，则修复max_phantom_processes
is_fixed=false
if $is_connected; then
    # Run the command "adb devices" and save the output to $devices_output.
    # 运行 adb devices 命令，并将输出保存到变量$devices_output中
    devices_output=$(adb devices | tail -n +2)
    # Extract the device identifier in the format localhost:port using regular expressions.
    # 使用正则表达式提取 localhost:port 格式的设备标识
    devices_regex="(localhost:[0-9]+)"
    if [[ $devices_output =~ $devices_regex ]]; then
        device_identifier=${BASH_REMATCH[1]}
        echo2log "device identifier: $device_identifier"
        echo2log "设备标识：$device_identifier"
        if $is_rollback; then
            # Rollback max_phantom_processes to default
            # 回滚 max_phantom_processes
            exec_prompt 'old_max_phantom_processes=$(grep "old_max_phantom_processes" "$CONFIGURATION_FILE" | cut -d'=' -f2)'
            echo2log "rollback max_phantom_processes to default, maybe is $old_max_phantom_processes"
            exec_prompt 'adb -s "$device_identifier" shell "/system/bin/device_config put activity_manager max_phantom_processes default"'
            exec_prompt 'adb -s "$device_identifier" shell "/system/bin/device_config set_sync_disabled_for_tests none"'
            # exec_prompt 'adb -s "$device_identifier" shell "/system/bin/dumpsys activity settings"'
            exec_prompt 'adb -s "$device_identifier" shell "/system/bin/dumpsys activity settings | grep max_phantom_processes"'
            if $disconnect_adb; then
                exec_prompt 'adb disconnect "$device_identifier"'
            fi
            is_fixed=true
            exec_prompt 'sed -i '/old_max_phantom_processes/d' "$CONFIGURATION_FILE"'
        else
            # Modify max_phantom_processes
            # 修改max_phantom_processes
            echo2log "update max_phantom_processes to 2147483647"
            old_max_phantom_processes=""
            exec_prompt 'old_max_phantom_processes=$(adb -s "$device_identifier" shell "/system/bin/dumpsys activity settings | grep max_phantom_processes | cut -d '=' -f2")'
            exec_prompt 'adb -s "$device_identifier" shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"'
            exec_prompt 'adb -s "$device_identifier" shell "/system/bin/device_config set_sync_disabled_for_tests persistent"'
            # exec_prompt 'adb -s "$device_identifier" shell "/system/bin/dumpsys activity settings"'
            exec_prompt 'adb -s "$device_identifier" shell "/system/bin/dumpsys activity settings | grep max_phantom_processes"'
            if $disconnect_adb; then
                exec_prompt 'adb disconnect "$device_identifier"'
            fi
            is_fixed=true
            if [ -z "$old_max_phantom_processes" ]; then
                old_max_phantom_processes=32
            fi
            exec_prompt 'echo2log "old_max_phantom_processes=$old_max_phantom_processes" >> "$CONFIGURATION_FILE"'
        fi
    fi
fi

# Terminate the adb server if it was started by this script
# 终止adb server，如果它是由本脚本启动的话
if $kill_adb; then
    exec_prompt 'adb kill-server'
fi

fixed_desc=""
fixed_desc_cn=""
if $is_rollback; then
    fixed_desc="Rollback"
    fixed_desc_cn="回滚"
else
    fixed_desc="Fix"
    fixed_desc_cn="修复"
fi
if ! $is_fixed; then
    echo2log "$fixed_desc max_phantom_processes failed"
    echo2log "${fixed_desc_cn}max_phantom_processes失败"
    back2home 1
else
    back2home 0
fi
