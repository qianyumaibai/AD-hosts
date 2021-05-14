# 该脚本将在卸载期间执行，您可以编写自定义卸载规则
work_dir=/sdcard/Android/ADhosts
syshosts=/system/etc/hosts
script_dir=${0%/*}/script
. $script_dir/select.ini
if [ $install_mod = "system" ]; then
   if [ -e $work_dir/syshosts.bak ];then
      mv -f $work_dir/syshosts.bak $syshosts
   else
      rm -rf $syshosts
      touch $syshosts
      echo "# Localhost (DO NOT REMOVE)" >> $syshosts
      echo "127.0.0.1	localhost" >> $syshosts
      echo " ::1	localhost ip6-localhost ip6-loopback" >> $syshosts
      chmod 644 $syshosts
      chown 0:0 $syshosts
      chcon u:object_r:system_file:s0 $syshosts
   fi
fi
rm -rf $work_dir