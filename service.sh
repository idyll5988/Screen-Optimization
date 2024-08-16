#!/system/bin/sh
while [[ "$(getprop sys.boot_completed)" -ne 1 ]] && [[ ! -d "/sdcard" ]];do sleep 1; done
while [[ `getprop sys.boot_completed` -ne 1 ]];do sleep 1; done
sdcard_rw() {
until [[ $(getprop sys.boot_completed) -eq 1 || $(getprop dev.bootcomplete) -eq 1 ]]; do sleep 1; done
}
sdcard_rw
[ ! "$MODDIR" ] && MODDIR=${0%/*}
MODPATH="/data/adb/modules/Screen"
source "${MODPATH}/scripts/X.sh"
km1() {
	echo -e "$@" >>优化.log
	echo -e "$@"
}
km2() {
	echo -e "❗️ $@" >>优化.log
	echo -e "❗️ $@"
}
[[ ! -e $MODDIR/scripts/ll/log ]] && mkdir -p $MODDIR/scripts/ll/log
to=$(which toybox 2>/dev/null || command -v toybox 2>/dev/null)
bu=$(which busybox 2>/dev/null || command -v busybox 2>/dev/null)
sq=$(which sqlite3 2>/dev/null || command -v sqlite3 2>/dev/null)
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
export ROOT=$({ROOT_PERMISSION})
rt() {
    if $ROOT; then
        echo "已ROOT"
        echo "su文件：`which -a su`"
    else
        echo "未ROOT"
    fi
}
root=$(magisk -c) 
cd ${MODDIR}/scripts/ll/log
log
chmod -R 0777 ${MODDIR}/scripts/*
crond -c ${MODDIR}/scripts
if [[ -d ${MODDIR}/scripts ]]; then
  start_time=$(date +%s.%N)
  for i in $(ls ${MODDIR}/scripts/*); do
    if [ -f "${i}" ]; then
    chmod 0777 "${i}"
	{
    su -c nohup "${i}" >/dev/null 2>&1 &
	} &
    while [ $(jobs | wc -l) -ge $thread_num ]; do
    sleep 1
    done
    wait
	end_time=$(date +%s.%N)
    elapsed=$(echo "$end_time - $start_time" | bc)
    formatted_time=$(printf "%.3f" $elapsed)
    echo "$date *已执行文件${i}用时$formatted_time秒*" >>优化.log
    fi
  done
else
  echo "$date*自定义服务文件夹不存在*" >>优化.log
fi
echo "$date *写入系统优化*" >>优化.log
echo "$date *👺ROOT状态=`rt`$root*" >>优化.log
if [ "$KSU" = "true" ]; then
echo "$date *👺KernelSU版本=$KSU_KERNEL_VER_CODE (kernel) + $KSU_VER_CODE (ksud)*" >>优化.log
elif [ "$APATCH" = "true" ]; then
APATCH_VER=$(cat "/data/adb/ap/version")
echo "$date *👺APatch版本=$APATCH_VER*" >>优化.log
else
echo "$date *👺Magisk=已安装*" >>优化.log
echo "$date *👺su版本=$(su -v)*" >>优化.log
echo "$date *👺Magisk版本=$(magisk -v)*" >>优化.log
echo "$date *👺Magisk版本号=$(magisk -V)*" >>优化.log
echo "$date *👺Magisk路径=$(magisk --path)*" >>优化.log
fi
if [ -n "$sq" ]; then
    SQLite_VERSION=$($sq -version)
    echo "$date *🗄SQLite位置: $sq*" >>优化.log
    echo "$date *🗄SQLite版本: $SQLite_VERSION*" >>优化.log
else
    echo "$date *🗄系统路径（PATH）中未找到sqlite3*" >>优化.log
fi
if [ -n "$bu" ]; then
    BUSYBOX_VERSION=$($bu uname -a)
    echo "$date *🗄Busybox位置: $bu*" >>优化.log
    echo "$date *🗄Busybox版本: $BUSYBOX_VERSION*" >>优化.log
else
    echo "$date *🗄系统路径（PATH）中未找到busybox*" >>优化.log
fi
if [ -n "$to" ]; then
    TOYBOX_VERSION=$($to --version)
    echo "$date *🗄toybox位置: $to*" >>优化.log
    echo "$date *🗄toybox版本: $TOYBOX_VERSION*" >>优化.log
else
    echo "$date *🗄系统路径（PATH）中未找到toybox*" >>优化.log
fi
echo "$date *🔋电池健康=$BATTERY_HEALTH%*" >>优化.log
echo "$date *🔋电池损耗=$battery_usage_percentage%*" >>优化.log

