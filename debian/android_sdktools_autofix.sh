#!/usr/bin/env bash
# Author: https://www.alainlam.cn

# Include util.sh
# 引入基础脚本工具
SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
source "$SCRIPT_PATH/../util/util.sh"

# ADB tools are necessary
# ADB工具是必须的
if ! [ -x "$(command -v adb)" ]; then
    is_install_adb=""
    while [[ $is_install_adb != "Y" && $is_install_adb != "y" && $is_install_adb != "N" && $is_install_adb != "n" ]]; do
        echo2log "This feature requires the adb tool, do you want to install it?(Y/n): "
        read2log "这个功能需要安装adb，你是否想要安装它？(Y/n): " is_install_adb
    done
    if [ $is_install_adb == "Y" ] || [ $is_install_adb == "y" ]; then
        exec_prompt 'bash $PROJECT_DIR/share/android_sdktools_download.sh'
        exec_prompt 'source $HOME/.profile'
    else
        back2home 1
    fi
fi

#### Define Variables
ANDROID_SDK_PATH=$ANDROID_SDK_HOME
MONITOR_DIRS=("platform-tools" "build-tools")
TARGET_DIRS=("$HOME/Android/android-sdk-tools")

#### Monitor SDK Directory for File Changes
checking_files() {
    local checking_file=$1
    file_name=$(basename "$checking_file")

    # If it is a directory, we need to traverse the entire directory again
    # as it may be a case of the entire directory being moved in
    if [ -d "$checking_file" ]; then
        files=($(ls "$checking_file"))
        for file in "${files[@]}"; do
            checking_files "$checking_file/$file"
        done
    else
        # Skip files that are already symbolic links
        if [ ! -L "$checking_file" ]; then
            target_file=""
            for dir in "${TARGET_DIRS[@]}"; do
                # Check if the corresponding file exists in the compilation tool directory
                target_file=$(find "$dir" -name "$file_name" -type f -print -quit)
                # If the file is found, break the loop
                if [ -n "$target_file" ]; then
                    break
                fi
            done

            # Found corresponding compilation tool file
            if [ -n "$target_file" ]; then
                # Remove the original compilation tool file
                rm -rf "$checking_file"
                # Create symbolic link
                ln -s "$target_file" "$checking_file"
                echo2log "Created symlink $checking_file -> $target_file"
            fi
        fi
    fi
}
# Set up file monitoring
inotifywait --exclude '^.*\.temp/.*' -mrq -e create,move "$ANDROID_SDK_PATH" | while read -r directory event file; do
    for monitor_dir in "${MONITOR_DIRS[@]}"; do
        if [[ "$directory$file" =~ $ANDROID_SDK_PATH$monitor_dir ]]; then
            checking_files "$directory$file"
        fi
    done
done
