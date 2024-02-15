#!/usr/bin/env bash
# Author: https://www.alainlam.cn

# Get the path of the current script to obtain the root directory of the project.
# 获取当前脚本的路径，从而获得项目的根目录
PROJECT_DIR=$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")
# Cache directory
# 缓存文件目录
CACHE_DIR="$PROJECT_DIR/.cache" && mkdir -p "$CACHE_DIR"
# Temporary directory
# 临时文件目录
TMP_DIR="$PROJECT_DIR/.tmp" && mkdir -p "$TMP_DIR"

# Configuration file path
# 配置文件路径
CONFIGURATION_FILE="$CACHE_DIR/termux-toy.conf"
if [ ! -f "$CONFIGURATION_FILE" ]; then
    touch "$CONFIGURATION_FILE"
    echo "Created At: $(date +"%Y-%m-%d %H:%M:%S")" >>"$CONFIGURATION_FILE"
fi
# Log file path
# 日志文件路径
LOG_FILE="$TMP_DIR/termux-toy.log"
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    echo "Created At: $(date +"%Y-%m-%d %H:%M:%S")" >>"$LOG_FILE"
fi

# Get the title: just to make it more convenient for developers to add other scripts without having to worry about the menu.
# 获取脚本标题: 只是为了让开发者更方便添加其他脚本而无需关注菜单
# 初始化变量
source "$PROJECT_DIR/util/title.sh"

# Logger
# 日志工具
echo2log() {
    local current_time
    local log_line
    current_time=$(date +"%Y-%m-%d %H:%M:%S")
    while IFS= read -r log_line || [[ -n "$log_line" ]]; do
        echo "$current_time: $log_line" >>"$LOG_FILE"
        echo "$log_line"
    done <<<"$1"
}

# Execute command with the prompt
# 运行并提示
exec_prompt() {
    echo2log "$1"
    eval "$1"
}

# This method reads user input, logs it to a file, and returns the input value.
# 该方法读取用户输入，将其记录到文件中，并返回输入值。
read2log() {
    local prompt="$1"
    local varname="$2"
    local input

    echo2log "$prompt"
    read -r input
    echo2log "Entered: $input"
    printf -v "$varname" '%s' "$input"
}

# Press the Enter key to return to the home menu
# 按下回车键返回主菜单
back2home() {
    local result="$1"
    local message
    local message_cn
    if [ "$1" == "1" ]; then
        message="failed!"
        message_cn="失败！"
    elif [ "$1" == "0" ]; then
        message="succeeded!"
        message_cn="成功！"
    else
        message="unknown!"
        message_cn="未知！"
    fi
    echo2log "Execution result: $message"
    echo2log "执行结果: $message_cn"
    echo2log "Press the Enter key to return to the home menu"
    echo2log "按下回车键返回主菜单"
    read
    exec_prompt 'exec "$PROJECT_DIR/menu.sh"'
}
