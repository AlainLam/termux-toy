#!/bin/bash
# Author: https://www.alainlam.cn

# 关闭所有xfce的进程
processes=$(pgrep -f xfce4)
for pid in $processes; do
    echo "killing $pid"
    kill "$pid"
done

# 关闭所有x11的进程
processes=$(pgrep -f com.termux.x11)
for pid in $processes; do
    echo "killing x11 server: $pid"
    kill "$pid"
done

# 关闭所有pulseaudio的进程
processes=$(pgrep -f pulseaudio)
for pid in $processes; do
    echo "killing pulseaudio: $pid"
    kill "$pid"
done

# 关闭所有 virgl renderer的进程
processes=$(pgrep -f virglrenderer-android)
for pid in $processes; do
    echo "killing virglrenderer-android: $pid"
    kill "$pid"
done

echo "Starting X11 server"
XDG_RUNTIME_DIR=$TMPDIR
termux-x11 :0 -ac &
# 一些设备只输出带有光标的黑屏需要使用传统绘图选项，比如Galaxy S8+
# https://github.com/termux/termux-x11/blob/master/README.md#running-graphical-applications
# termux-x11 :0 -legacy-drawing &
sleep 3

echo "Starting pulseaudio server"
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

echo "Starting Virgl Renderer"
virgl_test_server_android &

# 跳转到Termux X11
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity

# 启动桌面环境
proot-distro login "$debian_alias" --user "$normal_user_name" --shared-tmp -- bash -c "export DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1; dbus-launch --exit-with-session startxfce4"
