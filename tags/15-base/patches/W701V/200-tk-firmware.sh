if [ -z "$FIRMWARE2" ]
then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "removing TCOM Webinterface"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www/tcom"

echo1 "copying AVM Webinterface"
mkdir "${FILESYSTEM_MOD_DIR}/usr/www/all"
"$TAR" -cf - -C "${DIR}/.tk/original/filesystem/usr/www/all" --exclude=html/de/usb . | "$TAR" -xf - -C "${FILESYSTEM_MOD_DIR}/usr/www/all"
ln -sf all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
ln -sf all "${FILESYSTEM_MOD_DIR}/usr/www/avm"

"$TAR" -cf - -C "${DIR}/.tk/original/filesystem/etc/default.Fritz_Box_7170/avm" . | "$TAR" -xkf - -C "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW701V/tcom"
ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW701V/tcom"

echo1 "copying mailer"
cp -a "${DIR}/.tk/original/filesystem/sbin/mailer" "${FILESYSTEM_MOD_DIR}/sbin"

echo1 "copying igdd"
cp -a "${DIR}/.tk/original/filesystem/sbin/igdd" "${FILESYSTEM_MOD_DIR}/sbin"
