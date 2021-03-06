[ "$FREETZ_TYPE_FON_WLAN_7270_16MB" == "y" -a "$FREETZ_TYPE_LANG_DE" == "y" ] || return 0

echo1 "applying 16MB patch"
if [ "$FREETZ_TYPE_LABOR_DSL" == "y" ];then
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/7270_labor_dsl_16MB_flash.patch"
elif [ "$FREETZ_TYPE_LABOR_PHONE" == "y" ];then
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/7270_labor_phone_16MB_flash.patch"
elif [ "$FREETZ_TYPE_LABOR_WLAN" == "y" ];then
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/7270_labor_wlan_16MB_flash.patch"
else
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/7270_16MB_flash.patch"
fi
