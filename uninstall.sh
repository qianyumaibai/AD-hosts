# 该脚本将在卸载期间执行，您可以编写自定义卸载规则
mv -f /sdcard/ADhosts/syshosts.bak /system/etc/hosts
rm -rf /sdcard/ADhosts