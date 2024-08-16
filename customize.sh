AUTOMOUNT=true
PROPFILE=true
POSTFSDATA=true
LATESTARTSERVICE=true
cd $MODPATH
StopInstalling() {
  rm -rf "/data/adb/modules/Thermals"
  exit 1
}
if [ "$BOOTMODE" ] && [ "$KSU" ]; then
  ui_print "▌*从 KernelSU应用程序安装"
elif [ "$BOOTMODE" ] && [ "$APATCH" ]; then
  ui_print "▌*从 APatch应用程序安装"
elif [ "$BOOTMODE" ] && [ "$MAGISK_VER_CODE" ]; then
  ui_print "▌*从 Magisk应用程序安装"
else
  ui_print "*********************************************************"
  ui_print "▌*! 不支持从 recovery 安装"
  ui_print "▌*! 请从 KernelSU、APatch 或 Magisk 应用程序安装"
  abort    "*********************************************************"
fi
service_dir="/data/adb/service.d"
if [ "$KSU" = "true" ]; then
  ui_print "▌*kernelSU版本: $KSU_VER ($KSU_VER_CODE)"
  [ "$KSU_VER_CODE" -lt 10683 ] && service_dir="/data/adb/ksu/service.d"
elif [ "$APATCH" = "true" ]; then
  APATCH_VER=$(cat "/data/adb/ap/version")
  ui_print "▌*APatch版本: $APATCH_VER"
else
  ui_print "▌*Magisk版本: $MAGISK_VER ($MAGISK_VER_CODE)"
fi
if [ ! -d "${service_dir}" ]; then
  mkdir -p "${service_dir}"
fi
if [ -d "/data/adb/modules/Thermals" ]; then
  rm -rf "/data/adb/modules/Thermals"
  ui_print "▌*已删除旧模块"
fi
EXTRACT() {
  ui_print "▌*为Magisk/KernelSU/APatch提取模块文件"
  unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2
}
EXTRACT
PERMISSION() {
  ui_print "▌*正在设置权限"
  set_perm_recursive $MODPATH root root 0777
}
PERMISSION
CHARGE_FULL=$(cat /sys/class/power_supply/battery/charge_full)
CHARGE_FULL_DESIGN=$(cat /sys/class/power_supply/battery/charge_full_design)
DIFFERENCE=$(( $CHARGE_FULL_DESIGN - $CHARGE_FULL ))
CAPACITY=$(( $CHARGE_FULL / 1000 ))
CAPACITY_DESIGN=$(( $CHARGE_FULL_DESIGN / 1000 ))
BATTERY_HEALTH=$(( 100 * $CAPACITY / $CAPACITY_DESIGN ))
design_capacity=$(awk '{printf "%.0f", $0/1000}' /sys/class/power_supply/battery/charge_full_design)
current_capacity=$(awk '{printf "%.0f", $0/1000}' /sys/class/power_supply/battery/charge_full)
percentage=$(expr $current_capacity \* 100 / $design_capacity)
battery_usage_percentage=$(expr 100 - $percentage)
ROM=$(getprop ro.build.description | awk '{print $1,$3,$4,$5}')
[[ $"ROM" == "" ]] && ROM=$(getprop ro.bootimage.build.description | awk '{print $1,$3,$4,$5}')
[[ $"ROM" == "" ]] && ROM=$(getprop ro.system.build.description | awk '{print $1,$3,$4,$5}')
ui_print "▌*  🅼 🅼 🆇   *" 
ui_print "▌*🛠️写入系统优化*" 
ui_print "▌*🕛执行日期=$(date)*"
ui_print "▌*📱系统信息=$(uname -a)*" 
ui_print "▌*👑名称ROM=$ROM ($(getprop ro.product.vendor.device))*" 
ui_print "▌*🔧内核=$(uname -r)-$(uname -v)*"
ui_print "▌*📱手机制造商=$(getprop ro.product.manufacturer)*" 
ui_print "▌*📱手机品牌=$(getprop ro.product.brand)*" 
ui_print "▌*📱设备型号=$(getprop ro.product.model)*" 
ui_print "▌*⛏️安全补丁=$(getprop ro.build.version.security_patch)*" 
ui_print "▌*🅰️Android版本=$(getprop ro.build.version.release)*" 
sleep 1
ui_print "▌*🔋当前电池百分比=$(cat /sys/class/power_supply/battery/capacity)%"
sleep 0.5
ui_print "▌*🔋电池设计=$design_capacity mAh"
sleep 0.5
ui_print "▌*🔋电池健康=$BATTERY_HEALTH%=$percentage%"
ui_print "▌*🔋电池损耗=$battery_usage_percentage%"
sleep 0.5
ui_print "▌*🔋电池剩余容量=$current_capacity mAh"
ui_print "▌*🛠️模块说明:$(grep_prop description "$MODPATH/module.prop")*"
ui_print "▌*🛠️完成优化*"

