OPTIONS_CFG="${FILESYSTEM_MOD_DIR}/etc/options.cfg"

echo1 "creating options.cfg"

if [ "$FREETZ_CREATE_SEPARATE_OPTIONS_CFG" != "y" ]; then
	echo2 "by symlinking it to .config"
	ln -snf .config $OPTIONS_CFG
else
	OPTIONS_FILES="$(find make/*/files/root/etc/init.d/rc.* make/*/files/root/etc/default.*/*_conf make/*/files/root/usr/lib/cgi-bin/*.cgi)"
	OPTIONS_NAMES="$(grep -hoE "FREETZ_REPLACE_KERNEL|FREETZ_AVMDAEMON_DISABLE_[A-Z0-9]*|EXTERNAL_FREETZ_PACKAGE[a-zA-Z0-9_]*|FREETZ_PACKAGE[a-zA-Z0-9_]*" $OPTIONS_FILES | sort -u)"
	for OPTIONS_CURRENT in $OPTIONS_NAMES; do
		OPTIONS_VALUE="$(eval echo \$$OPTIONS_CURRENT)"
		if [ "$OPTIONS_VALUE" != "n" -a "$OPTIONS_VALUE" != "" ]; then
			echo2 "adding $OPTIONS_CURRENT"
			echo "$OPTIONS_CURRENT='$OPTIONS_VALUE'" >> $OPTIONS_CFG
		fi
	done
fi
