#!/bin/sh

## Store 'clean' environment for later use
if [ ! -e /var/env.cache ]; then
	export -p | grep '^export [A-Z]' > /var/env.cache
fi

cd /
export TERM=xterm

DAEMON=mod
. /etc/init.d/modlibrc

start() {
	echo "rc.mod version $(cat /etc/.freetz-version)"

	# Basic Packages
	for pkg in crond swap telnetd webcfg websrv dsld ftpd multid; do
		rc="/etc/init.d/rc.$pkg"
		[ -e "/mod$rc" ] || ln -s "$rc" "/mod$rc"
	done

	[ -d /tmp/flash ] || /usr/bin/modload

	/etc/init.d/rc.crond
	/etc/init.d/rc.telnetd
	/etc/init.d/rc.webcfg
	/etc/init.d/rc.swap

	# Static Packages
	[ "$MOD_EXTERNAL_FREETZ_SERVICES" == "yes" ] && EXTERNAL_SERVICES="$(cat /etc/external.pkg 2>/dev/null)"
	for pkg in $(cat /etc/static.pkg 2>/dev/null); do
		if [ -x "/etc/init.d/rc.$pkg" ]; then
			if echo " $EXTERNAL_SERVICES $MOD_EXTERNAL_OWN_SERVICES " | grep -q " $pkg " >/dev/null 2>&1; then
				echo "$pkg will be started by external."
			else
				modreg daemon $pkg
				"/etc/init.d/rc.$pkg"
			fi
		fi
	done

	# AVM-Plugins
	plugins=$(ls /var/plugin-*/control 2>/dev/null)
	if [ -n "$plugins" ]; then
		echo -n "Starting AVM-Plugins"
		for plugin in $plugins; do
			echo -n " ... $(echo $plugin | sed 's/.*plugin-//;s/\/.*//')"
			$plugin start >/dev/null 2>&1
			[ $? -ne 0 ] && echo -n "(failed)"
		done
		echo " ... done."
	fi

	[ -r /tmp/flash/rc.custom ] && mv /tmp/flash/rc.custom /tmp/flash/mod/rc.custom
	[ -r /tmp/flash/mod/rc.custom ] && . /tmp/flash/mod/rc.custom

	[ -x /etc/init.d/rc.external ] && touch /tmp/.modstarted

	/usr/lib/mod/menu-update
}

modreg_file() {
	local file=$1 sec_level=$2
	local basename=${file//./_}
	modreg file mod "$basename" "Freetz: $file" "$sec_level" "$basename"
}

register() {
	modreg_file  .profile    0
	modreg_file  hosts       1
	modreg_file  modules     0
	modreg_file  rc.custom   0

	/usr/lib/mod/reg-status start
}

case $1 in
	"")
		register
		start
		;;
	start)
		start
		;;
	*)
		echo "Usage: $0 [start]" 1>&2
		exit 1
		;;
esac
