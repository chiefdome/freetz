[ "$DS_PATCH_USBSTORAGE" == "y" ] || return 0
echo1 "applying USB storage patch"
if [ "$DS_TYPE_2170" == "y" ] || \
	[ "$DS_TYPE_FON_WLAN_7140" == "y" -a "$DS_TYPE_LANG_DE" == "y" ] || \
	[ "$DS_TYPE_FON_7150" == "y" ] || \
	[ "$DS_TYPE_WLAN_3130" == "y" ] || \
	[ "$DS_TYPE_WLAN_3131" == "y" ] || \
	[ "$DS_TYPE_WLAN_3170" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_wotam.patch"
elif [ "$DS_TYPE_SPEEDPORT_W900V" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_w900v.patch"
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage.patch"
fi

