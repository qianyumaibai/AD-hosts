##########################################################################################
#
# Magisk模块安装脚本
#
##########################################################################################
##########################################################################################
#
# 使用说明:
#
# 1. 将文件放入系统文件夹(删除placeholder文件)
# 2. 在module.prop中填写您的模块信息
# 3. 在此文件中配置和调整
# 4. 如果需要开机执行脚本，请将其添加到post-fs-data.sh或service.sh
# 5. 将其他或修改的系统属性添加到system.prop
#
##########################################################################################
##########################################################################################
#
# 安装框架将导出一些变量和函数。
# 您应该使用这些变量和函数来进行安装。
#
# !请不要使用任何Magisk的内部路径，因为它们不是公共API。
# !请不要在util_functions.sh中使用其他函数，因为它们也不是公共API。
# !不能保证非公共API在版本之间保持兼容性。
#
# 可用变量:
#
# MAGISK_VER (string):当前已安装Magisk的版本的字符串(字符串形式的Magisk版本)
# MAGISK_VER_CODE (int):当前已安装Magisk的版本的代码(整型变量形式的Magisk版本)
# BOOTMODE (bool):如果模块当前安装在Magisk Manager中，则为true。
# MODPATH (path):你的模块应该被安装到的路径
# TMPDIR (path):一个你可以临时存储文件的路径
# ZIPFILE (path):模块的安装包（zip）的路径
# ARCH (string): 设备的体系结构。其值为arm、arm64、x86、x64之一
# IS64BIT (bool):如果$ARCH(上方的ARCH变量)为arm64或x64，则为true。
# API (int):设备的API级别（Android版本）
#
# 可用函数:
#
# ui_print <msg>
#     打印(print)<msg>到控制台
#     避免使用'echo'，因为它不会显示在定制recovery的控制台中。
#
# abort <msg>
#     打印错误信息<msg>到控制台并终止安装
#     避免使用'exit'，因为它会跳过终止的清理步骤
#
##########################################################################################

##########################################################################################
# 变量
##########################################################################################

# 如果您需要更多的自定义，并且希望自己做所有事情
# 请在custom.sh中标注SKIPUNZIP=1
# 以跳过提取操作并应用默认权限/上下文上下文步骤。
# 请注意，这样做后，您的custom.sh将负责自行安装所有内容。
SKIPUNZIP=1
# 如果您需要调用Magisk内部的busybox
# 请在custom.sh中标注ASH_STANDALONE=1
ASH_STANDALONE=1

##########################################################################################
# 替换列表
##########################################################################################

# 列出你想在系统中直接替换的所有目录
# 查看文档，了解更多关于Magic Mount如何工作的信息，以及你为什么需要它


# 按照以下格式构建列表
# 这是一个示例
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# 在这里建立您自己的清单
REPLACE="
"
##########################################################################################
# 安装设置
##########################################################################################
 
# 将 $ZIPFILE 提取到 $MODPATH
ui_print "- 解压模块文件"
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2

work_dir=/sdcard/Android/ADhosts
syshosts=/system/etc/hosts

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
   echo "sh /data/adb/modules/AD-Hosts/script/functions.sh" >> $work_dir/Start.sh
fi

chmod -R 0755 $MODPATH/tools
chooseport() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
  [ "$1" ] && local delay=$1 || local delay=3
  local error=false
  while true; do
    timeout 0 $MODPATH/tools/$ARCH32/keycheck
    timeout $delay $MODPATH/tools/$ARCH32/keycheck
    local SEL=$?
    if [ $SEL -eq 42 ]; then
      return 0
    elif [ $SEL -eq 41 ]; then
      return 1
    else
      $error && abort "- 音量键错误!"
      error=true
      echo "- 未检测到音量键。再试一次。"
    fi
  done
}

ui_print "选择自动更新的地址"
ui_print "  音量+ = GitHub链接(国外推荐)"
ui_print "  音量– = Coding镜像链接(国内推荐)"
if chooseport; then
  ui_print "已选择GitHub链接"
  sed -i "s/<link>/https:\/\/raw.githubusercontent.com\/E7KMbb\/AD-hosts\/master\/system\/etc\/hosts/g" $MODPATH/script/select.ini
else
  ui_print "已选择Coding镜像链接"
  sed -i "s/<link>/https:\/\/aisauce.coding.net\/p\/ad-hosts\/d\/ad-hosts\/git\/raw\/master\/system\/etc\/hosts/g" $MODPATH/script/select.ini
fi

ui_print "选择hosts安装模式"
ui_print "  音量+ = systemless"
ui_print "  音量– = system"
if chooseport; then
  ui_print "已选择systemless模式"
  sed -i "s/<mod>/systemless/g" $MODPATH/script/select.ini
else
  ui_print "已选择system模式"
  sed -i "s/<mod>/system/g" $MODPATH/script/select.ini
  if [ ! -e $work_dir/syshosts.bak ]; then
     ui_print "备份系统hosts文件至$work_dir/hosts.bak"
     cp $syshosts $work_dir/syshosts.bak
  fi
  mount -o remount,rw /system
  if [ $? -gt 0 ]; then
      mount -o remount,rw /
  fi
  mv -f $MODPATH/system/etc/hosts $syshosts
  mount -o remount,ro /system
  if [ $? -gt 0 ]; then
      mount -o remount,ro /
  fi
  rm -rf $MODPATH/system
fi

var_miui="`grep_prop ro.miui.ui.version.*`"
if [ $var_miui ]; then
  ui_print " "
  ui_print "是否加入api.ad.xiaomi.com"
  ui_print "加入会教导致小米应用商城里的积分商城与红包功能无法使用"
  ui_print "但会屏蔽掉更多的来自小米的广告"
  ui_print "  音量+ = 加入"
  ui_print "  音量– = 不加入"
  if chooseport; then
    ui_print "已选择加入"
    ui_print "正在写入中....."
    sed -i "s/<adxiaomi>/api.ad.xiaomi.com/g" $MODPATH/system/etc/hosts
    sed -i "s/<xiaomi>/true/g" $MODPATH/script/select.ini
  else
    ui_print "已选择不加入"
    sed -i "s/<xiaomi>/false/g" $MODPATH/script/select.ini
  fi
else
  sed -i "s/<adxiaomi>/api.ad.xiaomi.com/g" $MODPATH/system/etc/hosts
  sed -i "s/<xiaomi>/true/g" $MODPATH/script/select.ini
fi
ui_print " "
ui_print "是否加入去除腾讯QQ微信小程序广告"
ui_print "加入会导致小程序无法看广告得奖励"
ui_print "  音量+ = 加入"
ui_print "  音量– = 不加入"
if chooseport; then
  ui_print "已选择加入"
  ui_print "正在写入中....."
  sed -i "s/<Tencentgamead1>/adsmind.gdtimg.com/g" $MODPATH/system/etc/hosts
  sed -i "s/<Tencentgamead2>/pgdt.gtimg.cn/g" $MODPATH/system/etc/hosts
  sed -i "s/<QQ>/true/g" $MODPATH/script/select.ini
else
  ui_print "已选择不加入"
  sed -i "s/<QQ>/false/g" $MODPATH/script/select.ini
fi

# 删除多余文件
 rm -rf \
 $MODPATH/system/placeholder $MODPATH/customize.sh \
 $MODPATH/*.md $MODPATH/.git* $MODPATH/LICENSE $MODPATH/tools 4>/dev/null

##########################################################################################
# 权限设置
##########################################################################################

  #如果添加到此功能，请将其删除

  # 请注意，magisk模块目录中的所有文件/文件夹都有$MODPATH前缀-在所有文件/文件夹中保留此前缀
  # 一些例子:
  
  # 对于目录(包括文件):
  # set_perm_recursive  <目录>                <所有者> <用户组> <目录权限> <文件权限> <上下文> (默认值是: u:object_r:system_file:s0)
  
  # set_perm_recursive $MODPATH/system/lib 0 0 0755 0644
  # set_perm_recursive $MODPATH/system/vendor/lib/soundfx 0 0 0755 0644

  # 对于文件(不包括文件所在目录)
  # set_perm  <文件名>                         <所有者> <用户组> <文件权限> <上下文> (默认值是: u:object_r:system_file:s0)
  
  # set_perm $MODPATH/system/lib/libart.so 0 0 0644
  # set_perm /data/local/tmp/file.txt 0 0 644

  # 默认权限请勿删除
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/script/functions.sh 0 0 777

