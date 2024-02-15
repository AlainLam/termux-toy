#!/usr/bin/env bash
# Author: https://www.alainlam.cn

# Get the title: just to make it more convenient for developers to add other scripts without having to worry about the menu.
# 获取脚本标题: 只是为了让开发者更方便添加其他脚本而无需关注菜单
is_script_title_makabaka_biubiubiu=""
for arg in "$@"; do
    case $arg in
    --is_script_title_makabaka_biubiubiu=*)
        is_script_title_makabaka_biubiubiu="${arg#*=}"
        ;;
    esac
done

if [ "$is_script_title_makabaka_biubiubiu" == "true" ]; then
    if ! grep -qE '(source|\.\s).*title\.sh.*' "$0"; then
        echo "_placeholder_script_title_makabaka_biubiubiu_none_n9HeHhZj"
        exit
    elif type title >/dev/null 2>&1; then
        script_title_makabaka_biubiubiu="$(title)"
        if [ -z "$script_title_makabaka_biubiubiu" ]; then
            echo "_placeholder_script_title_makabaka_biubiubiu_none_n9HeHhZj"
        fi
        echo "$script_title_makabaka_biubiubiu"
        exit
    fi
fi
