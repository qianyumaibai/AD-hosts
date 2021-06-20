#!/system/bin/sh
# ADhosts在使用system安装模式后关闭模块还原syshosts.bak
work_dir=/sdcard/Android/ADhosts
syshosts=/system/etc/hosts

. /data/adb/modules/AD-Hosts/script/select.ini

if [ $install_mod = "system" ]; then
   if [ -e /data/adb/modules/AD-Hosts/disable ]; then
      cp -f $work_dir/syshosts.bak $syshosts
   fi
fi