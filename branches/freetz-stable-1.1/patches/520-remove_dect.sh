[ "$FREETZ_REMOVE_DECT" == "y" ] || return 0
echo1 "removing DECT files"
for files in \
	lib/modules/2.6.??.?/kernel/drivers/isdn/avm_dect lib/modules/2.6.??.?/kernel/drivers/char/dect_io usr/bin/dect_manager \
	usr/share/ctlmgr/libdect.so bin/supportdata.dect sbin/start_dect_update.sh \
	$(find ${FILESYSTEM_MOD_DIR} -iwholename "*usr/www/*/html/*dect*" -printf "%P\n"); do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done
[ "$FREETZ_REMOVE_MINID" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libfoncclient.so*"

echo1 "patching web UI"
modsed "s/document.write(Dect.\{1,10\}(.*))//g" "${HTML_LANG_MOD_DIR}/html/de/home/home.html"
modsed "/jslGoTo('dect'/d;/^<?.*[dD]ect.*?>$/d" "${HTML_LANG_MOD_DIR}/html/de/menus/menu2_konfig.html"

echo1 "patching rc.S"
sed -i -e "s/^modprobe dect_io$//g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

echo1 "patching rc.conf"
sed -i -e "s/\(CONFIG_.*DECT.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
