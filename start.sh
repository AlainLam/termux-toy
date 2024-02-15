#!/usr/bin/env bash
# Author: https://www.alainlam.cn

# Git is necessary
# Git是必须的
# if ! [ -x "$(command -v git)" ]; then
#   is_install_git=""
#   while [[ $is_install_git != "Y" && $is_install_git != "y" && $is_install_git != "N" && $is_install_git != "n" ]]; do
#     echo 'This tools requires git, do you want to install it?:(Y/n)'
#     read -r -p "这个工具需要安装git，你是否想要安装它？（Y/n）: " is_install_git
#   done
#   if [[ "$is_install_git" == "N" || "$is_install_git" == "n" ]]; then
#     echo "Aha, see you!"
#     echo "退出脚本！"
#     exit
#   fi
#   pkg install git -y
# fi

# download the opensource code
# 下载开源代码
if [ ! -d "$HOME/termux-toy/" ]; then
  # git clone https://github.com/AlainLam/termux-package.git "$HOME/termux-toy"
  curl -sSL https://github.com/AlainLam/termux-toy/archive/refs/heads/main.zip -o "$HOME/termux-toy.zip"
  unzip -q "$HOME/termux-toy.zip" >/dev/null 2>&1
  rm -rf "$HOME/termux-toy.zip"
  mv "$HOME/termux-toy-main" "$HOME/termux-toy"
else
  is_update_code=""
  while [[ $is_update_code != "Y" && $is_update_code != "y" && $is_update_code != "N" && $is_update_code != "n" ]]; do
    echo 'Do you want to update the code to the latest?:(Y/n)'
    read -r -p "你想要更新代码到最新吗？（Y/n）: " is_update_code
  done
  if [[ "$is_update_code" == "Y" || "$is_update_code" == "y" ]]; then
    # git pull
    # backup old code
    current_time=$(date +"%Y%m%d%H%M%S")
    mv "$HOME/termux-toy" "$HOME/termux-toy-$current_time"
    # renew the code
    curl -sSL https://github.com/AlainLam/termux-toy/archive/refs/heads/main.zip -o $HOME/termux-toy.zip
    unzip -q $HOME/termux-toy.zip >/dev/null 2>&1
    rm -rf "$HOME/termux-toy.zip"
    mv "$HOME/termux-toy-main" "$HOME/termux-toy"
  fi
fi
cd "$HOME/termux-toy/" || exit

# Update script permissions
# 修改脚本权限
cd "$HOME/termux-toy/"
chmod -R a+x "./"
# git config core.filemode false

# Create a symlink link to the code repository in the tmp directory for sharing with proot-distro container
# 在tmp目录中创建代码库软链接以便共享给容器
rm -rf "$PREFIX/tmp/termux-toy"
ln -s "$HOME/termux-toy" "$PREFIX/tmp/termux-toy"

# start the menu script
# 启动菜单脚本
exec "$HOME/termux-toy/menu.sh"
