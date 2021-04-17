# 该脚本将在卸载期间执行，您可以编写自定义卸载规则
work_dir=/sdcard/ADhosts
syshosts=/system/etc/hosts
if [ -e $work_dir/syshosts.bak ];then
   mv -f $work_dir/syshosts.bak $syshosts
else
   rm -rf $syshosts
   touch $syshosts
   echo "# Localhost (DO NOT REMOVE)" >> $syshosts
   echo "127.0.0.1	localhost" >> $syshosts
   echo " ::1	localhost ip6-localhost ip6-loopback" >> $syshosts
fi
rm -rf $work_dir