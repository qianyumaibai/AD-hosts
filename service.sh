# This script will be executed in late_start service mode
# More info in the main Magisk thread
#set permissions
chmod 600 $MODPATH/./system/etc/hosts
set_perm $MODPATH/system/etc/hosts 0 0 0600