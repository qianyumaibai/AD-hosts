var_miui="`grep_prop ro.miui.ui.version.*`"
if [ $var_miui ]; then
  ui_print " "
  ui_print "是否加入api.ad.xiaomi.com"
  ui_print "加入会教导致小米应用商城里的积分商城与红包功能无法使用"
  ui_print "但会屏蔽掉更多的来自小米的广告"
  ui_print "  音量+ = 加入"
  ui_print "  音量- = 不加入"
  if $VKSEL; then
    ui_print "已选择加入"
    ui_print "正在写入中....."
    sed -i "s/<adxiaomi>/api.ad.xiaomi.com/g" $MODPATH/system/etc/hosts
  else
    ui_print "已选择不加入"
  fi
else
  sed -i "s/<adxiaomi>/api.ad.xiaomi.com/g" $MODPATH/system/etc/hosts
fi
  ui_print " "
  ui_print "是否加入去除腾讯QQ微信小程序广告"
  ui_print "加入会导致小程序无法看广告得奖励"
  ui_print "  音量+ = 加入"
  ui_print "  音量- = 不加入"
  if $VKSEL; then
    ui_print "已选择加入"
    ui_print "正在写入中....."
    sed -i "s/<Tencentgamead1>/adsmind.gdtimg.com/g" $MODPATH/system/etc/hosts
    sed -i "s/<Tencentgamead2>/pgdt.gtimg.cn/g" $MODPATH/system/etc/hosts
  else
    ui_print "已选择不加入"
  fi
