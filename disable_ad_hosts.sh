#!/system/bin/sh
# ADhosts在使用system安装模式后关闭模块还原syshosts.bak
work_dir=/sdcard/Android/ADhosts
syshosts=/system/etc/hosts

. /data/adb/modules/AD-Hosts/script/select.ini

if [ $install_mod = "system" ]; then
   if [ -e /data/adb/modules/AD-Hosts/disable ]; then
      for mount_path in /system /; do
         mount -o remount,rw ${mount_path} &> /dev/null
         if [ -w ${mount_path} ]; then
         break;
         else
            if [ ${mount_path} = / ]; then
               exit 0
            fi
         fi
      done
      cp -f $work_dir/syshosts.bak $syshosts
      chmod 644 $syshosts
      chown 0:0 $syshosts
      chcon u:object_r:system_file:s0 $syshosts
      mount -o remount,ro ${mount_path} &> /dev/null
   fi
fi