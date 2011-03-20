# Partially copied from sp-to-fritz by spirou & jpascher

isFreetzType W701V_7170 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi
echo1 "adapt firmware for W701V"

echo2 "deleting obsolete files"
rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit*"
for i in fs/ext2 fs/fat fs/isofs fs/nls fs/vfat fs/mbcache.ko drivers/usb drivers/scsi; do
	rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/$i"
done
for i in bin/pause bin/reinit_jffs2 bin/usbhostchanged etc/hotplug \
	etc/usb_class.tab etc/usb_device.tab etc/samba_control \
	lib/libusbcfg* usr/share/ctlmgr/libctlusb.so \
	usr/www/all/html/de/usb	sbin/lsusb etc/hotplug;do
	rm_files "${FILESYSTEM_MOD_DIR}/$i"
done

echo2 "copying W701V files"
cp "${DIR}/.tk/original/filesystem/etc/led.conf" "${FILESYSTEM_MOD_DIR}/etc/led.conf"
cp "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio/kernel/drivers/char/Piglet/Piglet.ko" \
	"${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/drivers/char/Piglet"
cp ${DIR}/.tk/original/filesystem/lib/modules/microvoip_isdn_top.bit* "${FILESYSTEM_MOD_DIR}/lib/modules"

echo2 "patching webmenu"
if isFreetzType LABOR_PREVIEW; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/intro_bar_middle_alien_7170_labor_preview.patch"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/sp2fritz-W701V_7170_labor_preview.patch" || exit 2
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/sp2fritz-W701V_7170.patch" || exit 2
fi

echo2 "moving default config dir, creating tcom and congstar symlinks"
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/congstar"
mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7170" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW701V"
ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW701V/tcom"
ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW701V/congstar"

echo2 "patching rc.S and rc.conf"
modsed "s/piglet_bitfile_offset=0 /piglet_bitfile_offset=0x51 /" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modsed "s/piglet_irq_gpio=18 /piglet_enable_button2=1 /" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modsed "/modprobe Piglet piglet_bitfile.*$/i \
piglet_load_params=\"\$piglet_load_params piglet_enable_switch=1\"" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
modsed "/piglet_irq=9.*$/d" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon Speedport W701V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_SpeedportW701V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ar7_8MB_xilinx_4eth_2ab_isdn_pots_wlan_13200\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

for var in CONFIG_CAPI_NT CONFIG_USB_STORAGE CONFIG_USB_PRINT_SERV CONFIG_USB_WLAN_AUTH CONFIG_USB_HOST_AVM CONFIG_USB_STORAGE_SPINDOWN; do
	modsed "s/$var=.*$/$var=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
done


echo2 "patching webinterface"
modsed "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon/sip1.js"
modsed "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon/siplist.js"
modsed "s/<? setvariable var:allprovider 0 ?>/<? setvariable var:allprovider 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/internet/authform.html"

echo2 "swapping info led"
#swap info led 0,1 with tr69 led
sed -i -e 's|DEF tr69,0 = 2,6,1,tr69|DEF tr69,0 = 99,32,16,tr69|' \
	-e 's|DEF info,0 = 99,32,16,info|DEF info,0 = 2,6,1,info|' \
	-e 's|DEF info,1 = 99,32,16,info|DEF info,1 = 2,6,1,info|' \
	-e 's|DEF info,2 = 99,32,16,info|DEF info,2 = 2,6,1,info|' \
	-e 's|DEF info,3 = 99,32,16,info|DEF info,3 = 2,6,1,info|' \
	-e 's|DEF info,4 = 99,32,16,info|DEF info,4 = 2,6,1,info|' "${FILESYSTEM_MOD_DIR}/etc/led.conf"

echo "DEF tam,0 = 99,32,21,tam" >> "${FILESYSTEM_MOD_DIR}/etc/led.conf"
# map tam info to power
echo "MAP tam,0 TO power,1" >> "${FILESYSTEM_MOD_DIR}/etc/led.conf"

#map stick_surf to info4, missed call to ata and adsl
echo "MAP stick_surf,0 TO info,4" >> "${FILESYSTEM_MOD_DIR}/etc/led.conf"

# Map ISDN LED to ab LED (config of original FRITZ!Box and replace it by Speedport's LED config)
if ! `cat "${FILESYSTEM_MOD_DIR}"/etc/init.d/rc.S | grep -q 'MAP isdn,0 TO ab,1'` ; then
modsed 's|ln -s /dev/new_led /var/led|ln -s /dev/new_led /var/led\
case $OEM in\
 tcom\|avm)\
 echo "STATES isdn,0 = 0 -> 2, 1 -> 4" >/dev/new_led\
 echo "MAP isdn,0 TO ab,1" >/dev/new_led\
 echo "STATES ab,1 = 1 -> 18, 0 -> 2, 4 -> 1" >/dev/new_led\
 ;;\
 avme)\
 ;;\
esac|' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

# patch install script to accept firmware from FBF or Speedport
echo1 "applying install patch"
if isFreetzType LABOR_PREVIEW; then
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/install-W701V_7170_labor_preview.patch" || exit 2
else
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/install-W701V_7170.patch" || exit 2
fi
