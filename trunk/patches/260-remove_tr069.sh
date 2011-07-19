[ "$FREETZ_REMOVE_TR069" == "y" ] || return 0

echo1 "removing tr069 stuff"
rm_files "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libtr064.so" \
	 "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libtr069.so" \
	 "${FILESYSTEM_MOD_DIR}/sbin/tr069discover"

if [ "$FREETZ_REMOVE_TR069_FWUPDATE" == "y" ]; then
	 rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/tr069fwupdate"
fi
echo1 "patching default tr069.cfg"
find ${FILESYSTEM_MOD_DIR}/etc -name tr069.cfg -exec sed -e 's/enabled = yes/enabled = no/' -i '{}' \;

if [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init" ]; then
	echo1 "patching /etc/init.d/rc.init"
	modsed "s/TR069=y/TR069=n/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init" "CONFIG_TR069=n$"
else
	echo1 "patching /etc/init.d/rc.conf"
	modsed "s/CONFIG_TR069=.*$/CONFIG_TR069=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf" "CONFIG_TR069=\"n\"$"
	modsed "s/CONFIG_TR064=.*$/CONFIG_TR064=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf" "CONFIG_TR064=\"n\"$"
fi

# delete tr069 config
echo "echo -n > /var/flash/tr069.cfg" > "${FILESYSTEM_MOD_DIR}/bin/tr069starter"
