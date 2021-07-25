#!/system/bin/sh
# 不要假设您的模块将位于何处。
# 如果您需要知道此脚本和模块的放置位置，请使用$MODDIR
# 这将确保您的模块仍能正常工作
# 即使Magisk将来更改其挂载点
MODDIR=${0%/*}

# 此脚本将在late_start service 模式执行
work_dir=/sdcard/Android/ADhosts
wait_count=0
until [ $(getprop sys.boot_completed) -eq 1 ] && [ -d "$work_dir" ]; do
  sleep 2
  wait_count=$((${wait_count} + 1))
  if [ ${wait_count} -ge 100 ] ; then
    exit 0
  fi
done

. $MODDIR/script/select.ini

if [ $update_boot_start = "true" ]; then
   sh $MODDIR/script/functions.sh
fi
if [ $regular_update_boot_start = "true" ]; then
   sh $MODDIR/script/cron.sh
fi
