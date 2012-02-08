if [ "$FREETZ_HAS_AVM_USB_HOST" == "y" -a "$FREETZ_PACKAGE_SAMBA" == "y" ]; then
	sed -i -e "/killall smbd*$/d" -e "s/pidof smbd/pidof/g" "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"
fi

if [ "$FREETZ_PACKAGE_SAMBA" == "y" || "$FREETZ_REMOVE_SMBD" == "y" ]; then
	echo1 "remove AVM samba config"
	rm_files \
		"${FILESYSTEM_MOD_DIR}/bin/inetdsamba" \
		"${FILESYSTEM_MOD_DIR}/sbin/samba_config_gen" \
		"${FILESYSTEM_MOD_DIR}/etc/samba_config.tar"
	echo1 "patching rc.net: renaming sambastart()"
	modsed 's/^\(sambastart *()\)/\1{ return; }\n_\1/' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net"
fi

if [ "$FREETZ_REMOVE_SMBD" == "y" ]; then
	echo1 "remove AVM-smbd files"
	rm_files \
		"${FILESYSTEM_MOD_DIR}/etc/samba_control" \
		"${FILESYSTEM_MOD_DIR}/sbin/smbd" \
		"${FILESYSTEM_MOD_DIR}/sbin/smbpasswd"
	echo1 "patching rc.conf: modifying CONFIG_SAMBA"
	modsed "s/CONFIG_SAMBA=.*$/CONFIG_SAMBA=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
fi

