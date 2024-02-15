#!/usr/bin/env bash
# Author: https://www.alainlam.cn

echo '
   _______    ______   __   __
  |__   __|  |  __  |  \ \ / /
     | |     | |  | |   \ | /
     | |     | |  | |    | |
     | |     | |__| |    | |
     |_|     |______|    |_|
'

# Iterate and execute each file ending with .sh to obtain the title value.
# 遍历并执行每个.sh结尾的文件，以得到title值
script_titles=()
script_paths=()

# Iterate through the "host" and "share" directories in the current directory.
# 遍历当前目录下的host和share目录
for dir in host share; do
    files=$(find "$dir" -type f -name "*.sh")
    for file in $files; do
        result=$(bash "$file" --is_script_title_makabaka_biubiubiu=true)
        if [[ "$result" != "_placeholder_script_title_makabaka_biubiubiu_none_n9HeHhZj" ]]; then
            script_titles+=("$result")
            script_paths+=("$(realpath "$file")")
        fi
    done
done

# Get the names of directories other than util, share, and host in the current directory, and save them for menu display.
# 获取当前目录下获取除了util, share, host三个目录之外的其他目录名，并保存起来用于菜单展示
exclude_dirs=("util" "share" "host")
directories_title=()
directories_paths=()

for dir in */; do
    dir=${dir%/}
    if [[ ! " ${exclude_dirs[@]} " =~ " ${dir} " ]]; then
        if [ ! -f "$dir/inlet.sh" ]; then
            continue
        fi
        result=$(bash "$dir/inlet.sh" --is_script_title_makabaka_biubiubiu=true)
        if [[ "$result" != "_placeholder_script_title_makabaka_biubiubiu_none_n9HeHhZj" ]]; then
            directories_title+=("$result")
            directories_paths+=("$(realpath "$dir")")
        fi
    fi

done

# Output the script titles
# 输出脚本标题
script_index=1
for title in "${script_titles[@]}"; do
    echo "[$script_index] $title"
    ((script_index++))
    echo ""
done

for title in "${directories_title[@]}"; do
    echo "[$script_index] ${title^}"
    ((script_index++))
    echo ""
done

# If input a invalid option, exit the script
# 如果输入一个无效的选项，则退出脚本
echo "[*] Exit script"
echo "    退出脚本"

# Get the script path based on the selected index
# 根据选择的下标获取脚本路径
read -r selected_index
if [[ $selected_index -gt 0 && $selected_index -le ${#script_paths[@]} ]]; then
    selected_script_path=${script_paths[$((selected_index - 1))]}
    bash "$selected_script_path"
elif [[ $selected_index -gt ${#script_paths[@]} && $selected_index -le $((${#script_paths[@]} + ${#directories_paths[@]})) ]]; then
    selected_directory_index=$((selected_index - ${#script_paths[@]} - 1))
    selected_directory_path=${directories_paths[$selected_directory_index]}
    bash "${selected_directory_path}/inlet.sh"
else
    echo "Aha! Goodbye!"
    echo "啊哈！再见"
fi
