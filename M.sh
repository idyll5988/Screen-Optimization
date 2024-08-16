#!/system/bin/sh
[ ! "$MODDIR" ] && MODDIR=${0%/*}
MODPATH="/data/adb/modules/Screen"
[[ ! -e ${MODDIR}/ll/log ]] && mkdir -p ${MODDIR}/ll/log
source "${MODPATH}/scripts/X.sh"
su -c am broadcast -a android.intent.action.SET_SCREEN_REFRESH_RATE -e refreshRate 120 -e fpsMode fixed





