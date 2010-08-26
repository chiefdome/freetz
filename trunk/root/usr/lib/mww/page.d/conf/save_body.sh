
start_stop() {
	local startORstop=$1
	local package=$2
	local oldstatus=$3
	local rc="/mod/etc/init.d/rc.${4-$2}"
	[ ! -x "$rc" ] && return
	case "$startORstop" in
		start)
			local newstatus=$(rc_status ${4-$2})
			[ "$oldstatus" == inetd -a "$newstatus" != inetd ] && /etc/init.d/rc.inetd config "$package"
			[ "$oldstatus" != stopped ] && "$rc" start
			;;
		stop)
			[ "$oldstatus" != stopped ] && "$rc" stop
			;;
	esac
}

apply_changes() {
	local startORstop=$1
	local package=$2
	if [ "$package" = mod ]; then
		start_stop $startORstop telnetd "$OLDSTATUS_telnetd"
		start_stop $startORstop swap "$OLDSTATUS_swap"
		if [ "$startORstop" == "start" -a "$OLDSTATUS_webcfg" != "stopped" ]; then
			echo "$(lang de:"Starte das Freetz-Webinterface in 9 Sekunden neu" en:"Restarting the Freetz webinterface in 9 seconds")!"
			/etc/init.d/rc.webcfg force-restart 9 >/dev/null 2>&1 &
		fi
		/usr/lib/mod/reg-status reload
	else
		start_stop $startORstop "$package" "$OLDSTATUS_PACKAGE"
	fi
}

rc_status() {
	local rc="/mod/etc/init.d/rc.$1"
	if [ -x "$rc" ]; then
		"$rc" status
	fi
}

default=false
case $QUERY_STRING in
	*default*) default=true ;;
esac

package=$PACKAGE

if $default; then
	echo "<p>$(lang de:"Konfiguration zur&uuml;cksetzen" en:"Restore default settings") ($PACKAGE_TITLE):</p>"
else
	echo "<p>$(lang de:"Konfiguration speichern" en:"Saving settings") ($PACKAGE_TITLE):</p>"
fi
echo -n "<pre class='log'>"

# redirect stderr to stdout so we see output in webif
exec 2>&1

back="mod status"
unset OLDSTATUS_telnetd OLDSTATUS_webcfg OLDSTATUS_swap

if $default; then
	hook=def
else
	hook=save
fi

# default functions for $package.save
pkg_pre_save() { :; }
pkg_apply_save() { :; }
pkg_post_save() { :; }
pkg_pre_def() { :; }
pkg_apply_def() { :; }
pkg_post_def() { :; }

# load package's implementation of these functions
if [ -r "/mod/etc/default.$package/$package.save" ]; then
	source "/mod/etc/default.$package/$package.save"
fi

if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
	if [ "$package" = mod ]; then
		back="mod conf"
		OLDSTATUS_telnetd=$(rc_status telnetd)
		OLDSTATUS_webcfg=$(rc_status webcfg)
		OLDSTATUS_swap=$(rc_status swap)
	else
		back="cgi $package"
		OLDSTATUS_PACKAGE=$(rc_status "$package")
	fi
	if ! $default; then
		prefix="$(echo "$package" | tr 'a-z\-' 'A-Z_')_"

		unset vars
		for var in $(modconf vars "$package"); do
			vars="${vars:+$vars:}${var#$prefix}"
		done

		settings=$(modcgi "$vars" "$package")
	fi
fi

pkg_pre_$hook | html

if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
	apply_changes stop "$package"
	echo
	if ! $default; then
		echo -n 'Saving settings ... '
		echo "$settings" | modconf set "$package" -
		echo 'done.'
		echo -n "Saving $package.cfg ... "
		modconf save "$package"
		echo 'done.'
	else
		echo -n 'Restoring defaults ... '
		modconf default "$package"
		echo 'done.'
	fi
	echo
	{
		apply_changes start "$package"
		pkg_apply_$hook
		echo
		modsave flash
	} | html
fi

pkg_post_$hook | html

echo '</pre>'
