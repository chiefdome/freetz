isFreetzType IAD_3331_7170 || return 0

echo1 "adapt firmware for IAD 3331"

echo2 "patching webmenu"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/intro_bar_middle_alien_7170.patch" || exit 2
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/iad2fritz-3331_7170.patch" || exit 2

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove-POTS-7170-alien.patch" || exit 2
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove-FON3-7170-alien.patch" || exit 2

modsed "s/CONFIG_AB_COUNT=.*$/CONFIG_AB_COUNT=\"2\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7170 HN\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7170_HN\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ar7_8MB_xilinx_4eth_2ab_wlan_usb_host_37264\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7170" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7170_HN"

# patch install script to accept firmware from 7170
echo1 "applying install patch"
modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/install-IAD_3331_7170.patch" || exit 2

