# 该脚本将在卸载期间执行，您可以编写自定义卸载规则
work_dir=/sdcard/ADhosts
if [ -e $work_dir/syshosts.bak ];then
   mv -f $work_dir/syshosts.bak /system/etc/hosts
fi
rm -rf $work_dir