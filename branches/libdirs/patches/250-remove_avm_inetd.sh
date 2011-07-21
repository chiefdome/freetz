[ "$FREETZ_PACKAGE_INETD" == "y" -a "$FREETZ_HAS_AVM_INETD" == "y" ] || return 0

echo1 "removing AVM inetd"

rm_files "${FILESYSTEM_MOD_DIR}/bin/inetdctl" # AVM wrapper / starter script for ftpd, samba and webdav
rm_files "${FILESYSTEM_MOD_DIR}/etc/inetd.conf" # AVM Symlink to /var/tmp/inetd.conf

# don't start inetd in rc.S
if (isFreetzType 7320 7240 7270_V2 7270_V3 || (isFreetzType 7390 && isFreetzType LABOR_PREVIEW)); then
	rm_files "${FILESYSTEM_MOD_DIR}/etc/init.d/S75-inetd"
else
	count=$(grep "usr/sbin/inetd" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S" | wc -l)
	if [ $count -gt 1 ]; then
		modsed '/if \[ \-x \/usr\/sbin\/inetd \] \; then/!b;:x1;/fi/!{N;bx1;};d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	else
		modsed '\@^/usr/sbin/inetd.*$@d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	fi
fi
