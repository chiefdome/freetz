[ "$FREETZ_TYPE_FON_WLAN_7240" == "y" \
	-o "$FREETZ_TYPE_FON_WLAN_7270" == "y" \
	-a "$FREETZ_TYPE_LANG_DE" == "y" ] \
  || return 0

echo1 "adding volume counter"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/470-volumecounter_${FREETZ_TYPE_STRING}.patch"

sed -i -e "s/CONFIG_VOL_COUNTER=\"n\"/CONFIG_VOL_COUNTER=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
