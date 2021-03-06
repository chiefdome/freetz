#!/bin/sh


. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

CHROOT=$(cat /mod/etc/lighttpd/lighttpd.conf | grep "server.chroot" | cut -d\" -f 2)
LOGA=$(cat /mod/etc/lighttpd/lighttpd.conf | grep "accesslog.filename" | cut -d\" -f 2)
LOGE=$(cat /mod/etc/lighttpd/lighttpd.conf | grep "server.errorlog" | cut -d\" -f 2)
if [ -n "$CHROOT" ]; then
	LOGA="$CHROOT/$LOGA"
	LOGE="$CHROOT/$LOGE"
fi

if [ "$FREETZ_PACKAGE_LIGHTTPD_MOD_ACCESSLOG" = "y" ]; then
	if [ -r "$LOGA" ]; then
		echo "<h1>lighttpd access log $LOGA</h1>"
		echo -n '<pre class="log">'
		html < $LOGA
		echo '</pre>'
	else
		echo "<h1>lighttpd access log unavailable</h1>"
	fi
else
	echo "<h1>mod_accesslog unavailable</h1>"
fi

if [ -r "$LOGE" ]; then
	echo "<h1>lighttpd access log $LOGE</h1>"
	echo -n '<pre class="log">'
	html < $LOGE
	echo '</pre>'
else
	echo "<h1>lighttpd error log unavailable</h1>"
fi
