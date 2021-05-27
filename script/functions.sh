#!/system/bin/sh
work_dir=/sdcard/Android/ADhosts
curdate="`date +%Y-%m-%d,%H:%M:%S`"
script_dir=${0%/*}

. $script_dir/select.ini

# 创建工作文件
if [ ! -d $work_dir ];then
   mkdir -p $work_dir
fi
if [ ! -e $work_dir/Cron.ini ];then
   touch $work_dir/Cron.ini
   echo "# 定时更新配置文件" >> $work_dir/Cron.ini
   echo "# 开关定时更新on/off" >> $work_dir/Cron.ini
   echo "regular_update=off" >> $work_dir/Cron.ini
   echo "M='0' && H='4' && DOM='*' && MO='*' && DOW='4'" >> $work_dir/Cron.ini
   echo "# *        *        *        *            *" >> $work_dir/Cron.ini
   echo "# -        -        -         -            -" >> $work_dir/Cron.ini
   echo "# |        |        |         |            |" >> $work_dir/Cron.ini
   echo "# |        |        |         |            +----- DOW=星期(0 - 7) (0和7都代表星期天)" >> $work_dir/Cron.ini
   echo "# |        |        |         +---------- MO=月份(1 - 12)" >> $work_dir/Cron.ini
   echo "# |        |        +--------------- DOM=日期(1 - 31)" >> $work_dir/Cron.ini
   echo "# |        +-------------------- H=小时(0 - 23)" >> $work_dir/Cron.ini
   echo "# +------------------------- M=分钟(0 - 59)" >> $work_dir/Cron.ini
   echo "# 例:" >> $work_dir/Cron.ini
   echo "# * * * * * 每分钟执行一次" >> $work_dir/Cron.ini
   echo "# * 4 * * * 每天的4:00执行一次" >> $work_dir/Cron.ini
   echo "# 每个时间(/4)" >> $work_dir/Cron.ini
   echo "# */4 * * * * 每4分钟执行一次" >> $work_dir/Cron.ini
   echo "# * */4 * * * 每4个小时执行一次" >> $work_dir/Cron.ini
   echo "# * * */4 * * 每4天执行一次" >> $work_dir/Cron.ini
   echo "# * * * */4 * 每4个月执行一次" >> $work_dir/Cron.ini
   echo "# * * * * */4 每4周执行一次" >> $work_dir/Cron.ini
   echo "# 一个时间到一个时间(0-59)" >> $work_dir/Cron.ini
   echo "# 25 8-11 * * * 每天8:00到11:00的第25分钟执行一次" >> $work_dir/Cron.ini
   echo "# 0 6-12/3 * * * 每天6:00到12:00每3小时0分钟执行一次" >> $work_dir/Cron.ini
   echo "# * 4 6-9 * * 每个月6-9号的4:00点执行一次" >> $work_dir/Cron.ini
   echo "# * 4 18 6-9 * 6-9月的每个18号的4:00点执行一次" >> $work_dir/Cron.ini
   echo "# * 4 * * 3-5 每周周3到周5的4:00点执行一次" >> $work_dir/Cron.ini
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

# 判断安装模式
if [ $install_mod = "systemless" ]; then
   hosts_dir=/data/adb/modules/AD-Hosts/system/etc
   if [ ! -d $hosts_dir ];then
      mkdir -p $hosts_dir
   fi
elif [ $install_mod = "system" ]; then
   hosts_dir=/system/etc
   if [ -d /data/adb/modules/AD-Hosts/system ];then
      rm -rf /data/adb/modules/AD-Hosts/system
   fi
else
   echo "Error: 没有变量请检查$script_dir/select.ini是否存在" >> $work_dir/update.log
   echo "Error: 没有变量请检查$script_dir/select.ini是否存在"
   exit 0
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
      echo "wget连接,更新失败: $curdate"
      rm -rf $work_dir/hosts
      exit 0
      fi
      done
else
      echo "Error: 您没有下载所需要用到的指令文件，请安装Busybox for Android NDK模块" >> $work_dir/update.log
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
   echo "没有更新: $curdate"
else
   if [ $install_mod = "system" ]; then
       mount -o remount,rw /system &> /dev/null
       if [ $? != 0 ]; then
           mount -o remount,rw / &> /dev/null
           if [ $? != 0 ]; then
              mount -o remount,rw /dev/block/bootdevice/by-name/system /system &> /dev/null
              if [ $? != 0 ]; then
                 echo "挂载失败请重新安装模块并选择systemless模式" >> $work_dir/update.log
                 echo "挂载失败请重新安装模块并选择systemless模式"
                 exit 0
              fi
           fi
       fi
   fi
   mv -f $work_dir/hosts $hosts_dir/hosts
   chmod 644 $hosts_dir/hosts
   chown 0:0 $hosts_dir/hosts
   chcon u:object_r:system_file:s0 $hosts_dir/hosts
   if [ $install_mod = "system" ]; then
       mount -o remount,ro /system &> /dev/null
       if [ $? != 0 ]; then
           mount -o remount,ro / &> /dev/null
           if [ $? != 0 ]; then
              mount -o remount,ro /dev/block/bootdevice/by-name/system /system &> /dev/null
           fi
       fi
   fi
   echo -n "上次更新时间: $curdate" >> $work_dir/update.log
   echo "  hosts文件目录:$hosts_dir/hosts" >> $work_dir/update.log
   sed -i '1d' $work_dir/update.log
   echo "更新成功"
fi

# 彩蛋
if (timeout 1 getevent -lc 1 2>&1 | grep EV_ABS > $script_dir/touch); then
   ui_print "恭喜你触发了本模块的彩蛋"
   . $script_dir/surprise.sh
fi
if [ -e $script_dir/touch ]; then
   rm -rf $script_dir/touch
fi
