#!/usr/bin/env bash
# Author: https://www.alainlam.cn

# Include util.sh
# 引入基础脚本工具
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "$SCRIPT_PATH/../util/util.sh"

# Show the title on menu
# 在菜单中显示标题
title() {
    echo "Debian Helper
    Debian 工具包"
}
source "$SCRIPT_PATH/../util/title.sh"

# alias list
# 别名列表
alias_selector() {
    local varname="$1"
    local alias_list=()
    echo2log "Please select a alias:"
    echo2log "请选择一个别名："
    local index=1
    for dir in "$PREFIX/var/lib/proot-distro/installed-rootfs"/*/; do
        alias="$(basename "$dir")"
        echo2log "${index}) $alias"
        alias_list+=("$alias")
        ((index++))
    done
    local choice
    local selected_alias=""
    while [[ -z "$selected_alias" ]]; do
        echo2log "Please select a valid option: "
        read2log "请选择一个有效的选项: " choice
        if [[ "$choice" =~ [0-9]+ && $choice -gt 0 ]]; then
            selected_alias="${alias_list[$((choice - 1))]}"
        fi
    done
    printf -v "$varname" '%s' "$selected_alias"
}

# user selector
# 用户选择器
user_selector() {
    local alias="$1"
    local varname="$2"
    local usernames=()
    usernames+=("root")
    # local normal_usernames=($(proot-distro login "$alias" -- bash -c 'getent passwd | awk -F: "\$3 >= 1000 {print \$1}"'))
    # local normal_usernames=($(proot-distro login d -- bash -c 'getent passwd | cut -d: -f1,3 | grep -E ":[0-9]{4}" | cut -d: -f2'))
    # usernames+=("${normal_usernames[@]}")
    distro_users=$(proot-distro login "$alias" -- bash -c 'cat /etc/passwd')
    while IFS= read -r line || [[ -n $line ]]; do
        uid=$(echo "$line" | cut -d: -f3)
        uname=$(echo "$line" | cut -d: -f1)
        if [[ $uid -ge 1000 ]]; then
            usernames+=($uname)
        fi
    done <<<"$distro_users"
    index=1
    for username in ${usernames[@]}; do
        echo2log "${index}) $username"
        ((index++))
    done
    local selected_username=""
    while [[ -z "$selected_username" ]]; do
        echo2log "Please select a valid username: "
        read2log "请选择一个有效的用户名: " choice
        if [[ "$choice" =~ [0-9]+ && $choice -gt 0 ]]; then
            selected_username="${usernames[$((choice - 1))]}"
        fi
    done
    printf -v "$varname" '%s' "$selected_username"
}

# Menu
# 菜单
while true; do
    # Read user input
    # 读取用户输入
    read2log '
  1) Create a new Debian with Desktop Env
     创建一个带桌面环境的Debian

  2) Install Code Server to your Debian
     向你的Debian安装Code Server

  3) Install Android Studio to your Debian
     向你的Debian中安装Android studio
  
  4) Create a shortcuts for your Debian
     为你的Debian桌面创建一个快捷方式

  *) Back to home menu
     返回主菜单
    ' debian_option
    
    debian_alias=""
    case $debian_option in
    1)
        echo2log 'Please enter a alias(default is debian): '
        read2log '请输入一个别名(默认是debian): ' debian_alias
        if [ -z "$debian_alias" ]; then
            debian_alias="debian"
            exec_prompt 'proot-distro install debian'
        else
            exec_prompt 'proot-distro install --override-alias "$debian_alias" debian '
        fi
        proot-distro login "$debian_alias" --shared-tmp -- bash -c "bash /tmp/termux-toy/debian/install.sh"
        ;;
    2)
        alias_selector debian_alias
        user_selector "$debian_alias" username
        exec_prompt 'proot-distro login "$debian_alias" --user "$username" --shared-tmp -- bash -c "bash /tmp/termux-toy/debian/install_code_server.sh"'
        ;;
    3)
        alias_selector debian_alias
        user_selector "$debian_alias" username
        exec_prompt 'proot-distro login "$debian_alias" --user "$username" --shared-tmp -- bash -c "bash /tmp/termux-toy/debian/install_code_server.sh"'
        ;;
    4)
        alias_selector debian_alias
        user_selector "$debian_alias" username
        shortcuts_name=""
        while [ -z "$shortcuts_name" ]; do
            echo2log 'Please enter a shortcuts name: '
            read2log '请输入一个快捷键名: ' shortcuts_name
        done
        mkdir -p "$HOME/.shortcuts"
        cp "$SCRIPT_PATH/shortcuts.sh" "$HOME/.shortcuts/${shortcuts_name}.sh"
        sed -i "s/\"\$normal_user_name\"/$username/g; s/\"\$debian_alias\"/$debian_alias/g" "$HOME/.shortcuts/${shortcuts_name}.sh"
        ;;
    *)
        exec_prompt 'exec "$PROJECT_DIR/menu.sh"'
        break
        ;;
    esac
done
