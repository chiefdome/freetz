#!/bin/sh

REG=/mod/etc/reg/daemon.reg

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

stat_begin() {
	echo '<table class="daemons" border="0" cellspacing="1" cellpadding="0">'
}

stat_button() {
	local daemon=$1 cmd=$2 active=$3
	if ! $active; then disabled=" disabled"; else disabled=""; fi
	echo "<td><form class='btn' action='/cgi-bin/service.cgi/$daemon' method='post'><input type='submit' name='cmd' value='$cmd'$disabled></form></td>"
}

stat_packagelink() {
	local url
	case $1 in
		crond|swap|telnetd|webcfg|dsld|ftpd) url=$(href mod conf) ;;
		*) url=$(href cgi "$1") ;;
	esac
	echo "<a href='$url'>$2</a>"
}

stat_line() {
	local daemon=$1
	local name=${2:-$daemon}
	local rcfile="/mod/etc/init.d/${3:-rc.$daemon}"
	local disable=${4:-false}
	local hide=${5:-false}
	local pkg=${6:-$daemon}

	$hide && return

	local start=false stop=false
	local status=$("$rcfile" status 2> /dev/null)
	case $status in
		running | 'running (inetd)')
			class=running
			stop=true
			;;
		stopped | 'stopped (inetd)')
			class=stopped
			start=true
			;;
		inetd)
			case $inetd_status in
				running)
					class=running
					;;
				stopped)
					class=stopped
					;;
				none)
					class=none
					inetd_status='<i>none</i>'
					;;
				*)	class=
					;;
			esac
			status="$inetd_status ($status)"
			;;
		none)
			status='<i>none</i>'
			class=none
			start=true
			;;
		*)
			class=
			start=true; stop=true
			;;
	esac
	echo "<tr${class:+ class='$class'}>"
	echo "<td width='180'>$(stat_packagelink "$pkg" "$name")</td><td class='status' width='120'>$status</td>"

	if $disable; then
		start=false; stop=false
	fi
	stat_button "$daemon" start $start
	stat_button "$daemon" stop $stop
	stat_button "$daemon" restart $stop

	echo '</tr>'
}

stat_end() {
	echo '</table>'
}

stat_avm() {
	sec_begin '$(lang de:"AVM-Dienste" en:"AVM services")'
	stat_begin

	stat_line dsld
	stat_line telnetd
	[ -x /etc/init.d/rc.ftpd ] && [ "$(echo usbhost.ftp_server_enabled | usbcfgctl -s)" != "no" ] && stat_line ftpd

	stat_end
	sec_end
}

stat_builtin() {
	sec_begin '$(lang de:"Basis-Pakete" en:"Built-in packages")'
	stat_begin

	stat_line crond
	stat_line swap
	stat_line webcfg

	stat_end
	sec_end
}

stat_static() {
	sec_begin '$(lang de:"Statische Pakete" en:"Static packages")'
	stat_begin

	if [ -r "$REG" ]; then
		while IFS='|' read -r daemon name rcscript disable hide pkg; do
			stat_line "$daemon" "$name" "$rcscript" "$disable" "$hide" "$pkg"
		done < "$REG"
	fi
	if [ ! -s "$REG" ]; then
		echo '<p><i>$(lang de:"keine statischen Pakete" en:"no static packages")</i></p>'
	fi

	stat_end
	sec_end
}

stat_dynamic() {
	sec_begin '$(lang de:"Dynamische Pakete" en:"Dynamic packages")'

	echo '<p><i>$(lang de:"(noch) nicht implementiert" en:"not implemented yet")</i></p>'

	sec_end
}

cgi_begin '$(lang de:"Dienste" en:"Services")' 'daemons'

view=$(cgi_param view | tr -d .)

if [ -e /etc/default.inetd/inetd.cfg ]; then
	inetd_status=$(/etc/init.d/rc.inetd status 2> /dev/null)
fi

# comment out dynamic packages until we implemented it

case $view in
	"")
		stat_avm
		stat_builtin
		stat_static
#		stat_dynamic
		;;
	builtin)
		stat_builtin
		;;
	static)
		stat_static
		;;
#	dynamic)
#		stat_dynamic
#		;;
	*)
		print_error "$(lang de:"Unbekannte Ansicht" en:"unknown view") '$view'"
		;;
esac

cgi_end
