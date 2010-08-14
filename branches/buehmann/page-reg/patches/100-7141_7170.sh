isFreetzType 7141_7170 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi
echo1 "adapt firmware for 7141"

echo2 "copying 7141 files"
cp "${DIR}/.tk/original/filesystem/lib/modules/microvoip_isdn_top.bit" "${FILESYSTEM_MOD_DIR}/lib/modules"

echo2 "deleting obsolete files"
rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit1"

#echo2 "patching webmenu"
#modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/7141_7170.patch"

echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_717* ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7141 || exit 2

echo2 "patching rc.S and rc.conf"

modsed "s/piglet_bitfile_offset=0/piglet_bitfile_offset=0x4b/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

modsed "s/CONFIG_AB_COUNT=.*$/CONFIG_AB_COUNT=\"2\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_ETH_COUNT=.*$/CONFIG_ETH_COUNT=\"1\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"40\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7141\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7141\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ar7_8MB_xilinx_1eth_2ab_isdn_te_pots_wlan_usb_host_49780\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/HWRevision_ATA=0$/HWRevision_ATA=1/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7170
echo1 "applying install patch"
if isFreetzType ANNEX_B; then
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/install-7141_7170.patch" || exit 2
else
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/install-7141_7170_Annex_A.patch" || exit 2
fi
