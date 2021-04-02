#!/system/bin/sh
work_dir=/sdcard/ADhosts
curdate="`date +%Y-%m-%d,%H:%M:%S`"
script_dir=${0%/*}

source $script_dir/select.ini

if [ ! -d $work_dir ];then
   mkdir -p $work_dir
fi
if [ ! -e $work_dir/update.log ];then
   touch $work_dir/update.log
   echo "paceholder" >> $work_dir/update.log
   sed -i "G;G;G;G;G" $work_dir/update.log
   sed -i '1d' $work_dir/update.log
fi
if [ ! -e $work_dir/Start.sh ];then
   touch $work_dir/Start.sh
   echo "# 手动更新，请使用root权限执行" >> $work_dir/Start.sh
   echo "sh $script_dir/functions.sh" >> $work_dir/Start.sh
fi

if [ $install_mod = "systemless" ]; then
   hosts_dir=/data/adb/modules/hosts/system/etc
elif [ $install_mod = "system" ]; then
   hosts_dir=/system/etc
else
   echo "Error: 没有变量请检查$script_dir/select.ini是否存在" >> $work_dir/update.log
   exit 0
fi

if $(curl -V > /dev/null 2>&1) ; then
    for i in $(seq 1 20); do
    if curl "${hosts_link}" -k -L -o "$work_dir/hosts" >&2; then
    break;
    fi
    sleep 2
    if [[ $i == 20 ]]; then
    echo "curl连接失败,更新失败: $curdate" >> $work_dir/update.log
    rm -rf $work_dir/hosts
    exit 0
    fi
    done
elif $(wget --help > /dev/null 2>&1) ; then
      for i in $(seq 1 5); do
      if wget --no-check-certificate ${hosts_link} -O $work_dir/hosts; then
      break;
      fi
      if [[ $i == 5 ]]; then
      echo "wget连接,更新失败: $curdate" >> $work_dir/update.log
      rm -rf $work_dir/hosts
      exit 0
      fi
      done
else
      echo "Error: 您没有下载所需要用到的指令文件，请安装Busybox for Android NDK模块" >> $work_dir/update.log
      exit 0
fi

if [ $MIUI = "true" ]; then
   sed -i "s/<adxiaomi>/api.ad.xiaomi.com/g" $work_dir/hosts
fi
if [ $Tencent = "true" ]; then
   sed -i "s/<Tencentgamead1>/adsmind.gdtimg.com/g" $work_dir/hosts
   sed -i "s/<Tencentgamead2>/pgdt.gtimg.cn/g" $work_dir/hosts
fi

Now=$(md5sum $hosts_dir/hosts | awk '{print $1}')
New=$(md5sum  $work_dir/hosts | awk '{print $1}')
ab_device=$(getprop ro.build.ab_update)
if [ $Now = $New ]; then
   rm -rf $work_dir/hosts
   echo "没有更新: $curdate" >> $work_dir/update.log
else
   if [ $install_mod = "system" ]; then
      if [ $ab_device = "true" ]; then
         mount -o remount,rw /
      else
         mount -o remount,rw /system
      fi
   fi
   mv -f $work_dir/hosts $hosts_dir/hosts
   chmod 644 $hosts_dir/hosts
   chown 0:0 $hosts_dir/hosts
   chcon u:object_r:system_file:s0 $hosts_dir/hosts
   if [ $install_mod = "system" ]; then
      if [ $ab_device = "true" ]; then
         mount -o remount,ro /
      else
         mount -o remount,ro /system
      fi
   fi
   echo -n "上次更新时间: $curdate" >> $work_dir/update.log
   echo "  hosts文件目录:$hosts_dir/hosts" >> $work_dir/update.log
   sed -i '1d' $work_dir/update.log
fi
