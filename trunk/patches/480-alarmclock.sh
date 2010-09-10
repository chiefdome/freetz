[ "$FREETZ_PATCH_ALARMCLOCK" == "y" ] || return 0
echo1 "adding alarm-clock"

if isFreetzType 7150 && isFreetzType LANG_DE; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${FREETZ_TYPE_LANG_STRING}/480-alarmclock_7150.patch"
elif isFreetzType 7112 7141 7170 && isFreetzType LANG_DE; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${FREETZ_TYPE_LANG_STRING}/480-alarmclock.patch"
elif isFreetzType 3270_V3; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/480-alarmclock_3270v3.patch"
elif isFreetzType 7270 7570 && ! isFreetzType LANG_DE; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${FREETZ_TYPE_LANG_STRING}/480-alarmclock_7270.patch"
elif isFreetzType 7240 7270 && isFreetzType PREVIEW; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/480-alarmclock_7270_preview.patch"
elif isFreetzType 7240 7270 && isFreetzType LABOR; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/480-alarmclock_7270_labor.patch"
elif isFreetzType 3270 7240 7270; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/480-alarmclock.patch"
fi

