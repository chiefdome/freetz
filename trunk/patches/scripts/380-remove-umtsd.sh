if [ "$FREETZ_REMOVE_UMTSD" == "y" -o "$FREETZ_REMOVE_ASSISTANT" == "y" ]; then
	modsed \
	  sed 's/\(^var umts = \).*/\10;/g' \
	  "${HTML_LANG_MOD_DIR}/html/logincheck.html"
	modsed \
	  's/\(^local start_umts.*\) =.*/\1 = false/g' \
	  "${HTML_LANG_MOD_DIR}/lua/first.lua"
fi

[ "$FREETZ_REMOVE_UMTSD" == "y" ] || return 0
echo1 "remove umtsd files"
rm_files \
  "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libgsm.so" \
  "${FILESYSTEM_MOD_DIR}/usr/bin/umtsd" \
  "${FILESYSTEM_MOD_DIR}/usr/bin/csvd" \
  "${FILESYSTEM_MOD_DIR}/usr/www/all/assis/internet_umts.lua"

echo1 "patching rc.conf"
modsed "s/CONFIG_USB_GSM=.*$/CONFIG_USB_GSM=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_USB_GSM_VOICE=.*$/CONFIG_USB_GSM_VOICE=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
