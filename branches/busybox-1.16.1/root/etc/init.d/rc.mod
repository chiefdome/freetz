#!/bin/sh

cd /
export TERM=xterm

. /etc/init.d/modlibrc

start() {
	echo "rc.mod version $(cat /etc/.freetz-version)"

	# Basic Packages
	for pkg in crond swap telnetd webcfg websrv; do
		rc="/etc/init.d/rc.$pkg"
		[ -e "/mod$rc" ] || ln -s "$rc" "/mod$rc"
	done

	[ -d /tmp/flash ] || /usr/bin/modload

	[ -r /tmp/flash/mod/resolv.conf ] || cat /var/tmp/resolv.conf > /tmp/flash/mod/resolv.conf

	/etc/init.d/rc.crond
	/etc/init.d/rc.telnetd
	/etc/init.d/rc.webcfg

	# Static Packages
	if [ -e /etc/static.pkg ]; then
		for pkg in $(cat /etc/static.pkg); do
			if [ -x "/etc/init.d/rc.$pkg" ]; then
				modreg daemon $pkg
				"/etc/init.d/rc.$pkg"
			fi
		done
	fi
	
	## Store 'clean' environment for later use (skipping IFS)
	if [ ! -e /var/env.cache ]; then
		set | sed -n "/^IFS=/ d; /^[A-Z]/ s/.*/export &/p" > /var/env.cache
	fi

	# AVM-Plugins
	plugins=$(ls /var/plugin-*/control 2>/dev/null)
	if [ -n "$plugins" ]; then
		echo -n "Starting AVM-Plugins"
		for plugin in $plugins; do
			echo -n "...$(echo $plugin|sed 's/.*plugin-//;s/\/.*//')"
			$plugin start >/dev/null 2>&1
			[ $? -ne 0 ] && echo -n "(failed)"
		done
		echo "...done."
	fi

	[ -r /tmp/flash/rc.custom ] && mv /tmp/flash/rc.custom /tmp/flash/mod/rc.custom
	[ -r /tmp/flash/mod/rc.custom ] && . /tmp/flash/mod/rc.custom

	/etc/init.d/rc.swap
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
	modreg_file  resolv.conf 0
	modreg_file  rc.custom   0

	[ -r "/mod/etc/conf/mod.cfg" ] && . /mod/etc/conf/mod.cfg
	modreg status mod '$(lang de:"Logdateien" en:"Logfiles")' logs
	[ "$MOD_MOUNTED_SUB" = yes ] && modreg status mod '$(lang de:"Partitionen" en:"Partitions")' mounted
	[ "$MOD_SHOW_BOX_INFO" = yes -a -r "/usr/lib/cgi-bin/mod/box_info.cgi" ] && modreg status mod 'BOX$(lang de:"-Info" en:" info")' box_info
	[ "$MOD_SHOW_FREETZ_INFO" = yes -a -r "/usr/lib/cgi-bin/mod/info.cgi" ] && modreg status mod 'FREETZ$(lang de:"-Info" en:" info")' info
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
