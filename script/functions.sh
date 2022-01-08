#!/system/bin/sh
work_dir=/sdcard/Android/ADhosts
curdate="`date +%Y-%m-%d,%H:%M:%S`"
script_dir=${0%/*}
modules_dir=$(dirname ${script_dir})
hosts_dir=${modules_dir}/system/etc

. $script_dir/select.ini

# 创建工作文件
if [ ! -d $work_dir ];then
   mkdir -p $work_dir
fi
if [ ! -e $work_dir/Cron.ini ];then
   touch $work_dir/Cron.ini
   echo "# 定时更新配置文件" >> $work_dir/Cron.ini
   echo "# 开关定时更新 on/off" >> $work_dir/Cron.ini
   echo "regular_update=off" >> $work_dir/Cron.ini
   echo "" >> $work_dir/Cron.ini
   echo "# 时间格式 24/AM/PM" >> $work_dir/Cron.ini
   echo "time_format=24" >> $work_dir/Cron.ini
   echo "# 时间" >> $work_dir/Cron.ini
   echo "time=4:00" >> $work_dir/Cron.ini
   echo "" >> $work_dir/Cron.ini
   echo "# 每周更新与每月更新关闭则为每日更新" >> $work_dir/Cron.ini
   echo "# 每周更新与每月更新不可同时开启" >> $work_dir/Cron.ini
   echo "# 每周更新 y/n" >> $work_dir/Cron.ini
   echo "wupdate=n" >> $work_dir/Cron.ini
   echo "# 星期几更新(必填) wupdate=y 时启用 (0 - 7) (0和7都代表星期天)" >> $work_dir/Cron.ini
   echo "wday=4" >> $work_dir/Cron.ini
   echo "" >> $work_dir/Cron.ini
   echo "# 每月更新 y/n" >> $work_dir/Cron.ini
   echo "mupdate=n" >> $work_dir/Cron.ini
   echo "# 几号更新(必填) mupdate=y 时启用 (1 - 31)" >> $work_dir/Cron.ini
   echo "wdate=9" >> $work_dir/Cron.ini
fi
if [ ! -e $work_dir/update.log ];then
   touch $work_dir/update.log
   echo "paceholder" >> $work_dir/update.log
   sed -i "G;G;G;G;G" $work_dir/update.log
   sed -i '1d' $work_dir/update.log
fi
if [ ! -e $work_dir/Regular_update.sh ];then
   touch $work_dir/Regular_update.sh
   echo "# 定时更新手动开关，开关状态请在Cron.ini中更改" >> $work_dir/Regular_update.sh
   echo "sh $script_dir/cron.sh" >> $work_dir/Regular_update.sh
fi
if [ ! -e $work_dir/Start.sh ];then
   touch $work_dir/Start.sh
   echo "# 手动更新，请使用root权限执行" >> $work_dir/Start.sh
   echo "sh $script_dir/functions.sh" >> $work_dir/Start.sh
fi

# 下载hosts文件
if $(curl -V > /dev/null 2>&1) ; then
    for i in $(seq 1 20); do
    if curl "${hosts_link}" -k -L -o "$work_dir/hosts" >&2; then
    break;
    fi
    sleep 2
    if [[ $i == 20 ]]; then
    echo "curl连接失败,更新失败: $curdate" >> $work_dir/update.log
    sed -i '1d' $work_dir/update.log
    echo "curl连接失败,更新失败: $curdate"
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
      sed -i '1d' $work_dir/update.log
      echo "wget连接,更新失败: $curdate"
      rm -rf $work_dir/hosts
      exit 0
      fi
      done
else
      echo "Error: 您没有下载所需要用到的指令文件，请安装Busybox for Android NDK模块" >> $work_dir/update.log
      sed -i '1d' $work_dir/update.log
      echo "Error: 您没有下载所需要用到的指令文件，请安装Busybox for Android NDK模块"
      exit 0
fi

# 判断用户选择
if [ $MIUI = "true" ]; then
   sed -i "s/<adxiaomi>/api.ad.xiaomi.com/g" $work_dir/hosts
fi
if [ $Tencent = "true" ]; then
   sed -i "s/<Tencentgamead1>/adsmind.gdtimg.com/g" $work_dir/hosts
   sed -i "s/<Tencentgamead2>/pgdt.gtimg.cn/g" $work_dir/hosts
fi

# 安装hosts文件
Now=$(md5sum $hosts_dir/hosts | awk '{print $1}')
New=$(md5sum  $work_dir/hosts | awk '{print $1}')
if [ $Now == $New ]; then
   rm -rf $work_dir/hosts
   echo "没有更新: $curdate" >> $work_dir/update.log
   sed -i '1d' $work_dir/update.log
   echo "没有更新: $curdate"
else
   mv -f $work_dir/hosts $hosts_dir/hosts
   chmod 644 $hosts_dir/hosts
   chown 0:0 $hosts_dir/hosts
   chcon u:object_r:system_file:s0 $hosts_dir/hosts
   echo -n "上次更新时间: $curdate" >> $work_dir/update.log
   echo "  hosts文件目录:$hosts_dir/hosts" >> $work_dir/update.log
   sed -i '1d' $work_dir/update.log
   echo "更新成功"
fi

# 彩蛋
if (timeout 1 getevent -lc 1 2>&1 | grep EV_ABS > $script_dir/touch); then
   echo "恭喜你触发了本模块的彩蛋"
   sh $script_dir/surprise.sh
fi
if [ -e $script_dir/touch ]; then
   rm -rf $script_dir/touch
fi
