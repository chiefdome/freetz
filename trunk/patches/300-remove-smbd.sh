[ "$FREETZ_PACKAGE_SAMBA" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/bin/inetdsamba"
[ "$FREETZ_REMOVE_SMBD" == "y" ] || return 0
echo1 "remove AVM-smbd files"
rm_files "${FILESYSTEM_MOD_DIR}/sbin/smbd" \
	 "${FILESYSTEM_MOD_DIR}/bin/inetdsamba" \
	 "${FILESYSTEM_MOD_DIR}/etc/samba_control" \
	 "${FILESYSTEM_MOD_DIR}/etc/samba_config.tar" \
	 "${FILESYSTEM_MOD_DIR}/sbin/smbpasswd"

echo1 "patching rc.conf"
modsed "s/CONFIG_SAMBA=.*$/CONFIG_SAMBA=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
