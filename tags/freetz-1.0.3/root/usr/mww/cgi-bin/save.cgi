#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

# redirect stderr to stdout so we see ouput in webif
exec 2>&1

update_inetd() {
	if [ -x /usr/bin/modinetd ]; then
		/usr/bin/modinetd --nosave "$1"
	fi
}

start_stop() {
	oldstatus=$2
	if [ -x "/mod/etc/init.d/rc.$1" ]; then
		status=$("/mod/etc/init.d/rc.$1" status)
		if [ running = "$oldstatus" -a inetd = "$status" ]; then
			"/mod/etc/init.d/rc.$1" stop
			update_inetd "$1"
			echo
		elif [ inetd = "$oldstatus" -a inetd != "$status" ]; then
			update_inetd "$1"
			"/mod/etc/init.d/rc.$1" start
			echo
		elif [ inetd = "$oldstatus" -o inetd = "$status" ]; then
			update_inetd "$1"
			echo
		elif [ running = "$oldstatus" ]; then
			"/mod/etc/init.d/rc.$1" restart
			echo
		fi
	fi
}

apply_changes() {
	echo
	if [ "$1" = mod ]; then
		start_stop telnetd "$2"
		start_stop webcfg "$3"
		start_stop swap "$4"
		. /mod/etc/conf/mod.cfg
		modunreg status mod mod/mounted
		[ "$MOD_MOUNTED_SUB" = yes ] && modreg status mod '$(lang de:"Partitionen" en:"Partitions")' mod/mounted
	else
		start_stop "$1" "$2"
	fi
}

rc_status() {
	if [ -x "/mod/etc/init.d/rc.$1" ]; then
		"/mod/etc/init.d/rc.$1" status
	else
		echo ""
	fi
}

# default functions for $package.save
pkg_pre_save() { :; }
pkg_apply_save() { :; }
pkg_post_save() { :; }
pkg_pre_def() { :; }
pkg_apply_def() { :; }
pkg_post_def() { :; }

cgi_begin "$(lang de:"Speichern" en:"Saving")..."

echo "<p>$(lang de:"Konfiguration speichern" en:"Saving settings"):</p>"
echo -n "<pre>"

form=$(echo "$QUERY_STRING" | sed -e 's/^.*form=//' -e 's/&.*$//' -e 's/\.//g')

script=status.cgi;
package=''
file_id=''
oldstatus1=''
oldstatus2=''
oldstatus3=''

case "$form" in
	pkg_*)
		package=${form#pkg_}
		[ -r "/mod/etc/default.$package/$package.save" ] && . "/mod/etc/default.$package/$package.save"
		pkg_pre_save | html
		if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
			if [ "$package" = mod ]; then
				script=settings.cgi
				oldstatus1=$(rc_status telnetd)
				oldstatus2=$(rc_status webcfg)
				oldstatus3=$(rc_status swap)
			else
				script=pkgconf.cgi
				oldstatus1=$("/mod/etc/init.d/rc.$package" status)
			fi
			prefix="$(echo "$package" | tr 'a-z\-' 'A-Z_')_"
			
			vars=''; delim=''
			for var in $(modconf vars "$package"); do
				vars="${vars}${delim}${var#$prefix}"
				delim=':'
			done

			echo -n 'Saving settings...'
			modcgi "$vars" "$package" | modconf set "$package" -
			echo 'done.'

			echo -n "Saving $package.cfg..."
			modconf save "$package"
			echo 'done.'
			
			{
			apply_changes "$package" "$oldstatus1" "$oldstatus2" "$oldstatus3"
			pkg_apply_save

			modsave flash
			} | html
		fi
		pkg_post_save | html
		;;
	def_*)
		package=${form#def_}
		[ -r "/mod/etc/default.$package/$package.save" ] && . "/mod/etc/default.$package/$package.save"
		pkg_pre_def | html

		if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
			if [ "$package" = mod ]; then 
				script=settings.cgi
				oldstatus1=$(rc_status telnetd)
                                oldstatus2=$(rc_status webcfg)
				oldstatus3=$(rc_status swap)
			else 
				script=pkgconf.cgi
                                oldstatus1=$("/mod/etc/init.d/rc.$package" status)
                        fi
			
			echo -n 'Restoring defaults...'
			modconf default "$package"
			echo 'done.'

			{
			apply_changes "$package" "$oldstatus1" "$oldstatus2" "$oldstatus3"
			pkg_apply_def

			modsave flash
			} | html
		fi
		pkg_post_def | html
		;;
	file_*)
		file_id=${form#file_}
		script=file.cgi

		[ -e /mod/etc/reg/file.reg ] || touch /mod/etc/reg/file.reg

		sec_level=1
		[ -r /tmp/flash/security ] && let sec_level=$(cat /tmp/flash/security)

		OIFS=$IFS
		IFS='|'
		set -- $(cat /mod/etc/reg/file.reg | grep "^$file_id|")
		IFS="$OIFS"

		[ -r "$4" ] && . "$4"

		if [ -z "$CONFIG_FILE" -o "$sec_level" -gt "$3" ]; then
			echo "Configuration file not available at the current security level!"
		else
			case "$CONFIG_TYPE" in
				text)
					eval "$(modcgi content mod_cgi)"
					echo -n "Saving $file_id..."
					echo "$MOD_CGI_CONTENT" > "$CONFIG_FILE"
					echo 'done.'
					eval "$CONFIG_SAVE"
					;;
				list)
					eval "$CONFIG_SAVE"
					;;
			esac
		fi
		;;
	*)
		echo "$(lang de:"Fehler: Unbekanntes Formular" en:"Error: unknown form") '$form'"
		;;
esac

echo '</pre>'
echo -n "<p><form action=\"/cgi-bin/$script\">"
[ -z "$package" ] || echo -n "<input type=\"hidden\" name=\"pkg\" value=\"$package\">"
[ -z "$file_id" ] || echo -n "<input type=\"hidden\" name=\"id\" value=\"$file_id\">"
echo '<input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></form></p>'

cgi_end
