#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

extra_reg=/mod/etc/reg/extra.reg
cgi_reg=/mod/etc/reg/cgi.reg

[ -e "$extra_reg" ] || touch "$extra_reg"

_cgi_extras() {
	if [ ! -s "$extra_reg" ]; then
		echo '<p><i>$(lang de:"keine Extras" en:"no extras")</i></p>'
		return
	fi
	[ -e "$cgi_reg" ] || touch "$cgi_reg"

	unset cur_pkg
	cat "$extra_reg" | while IFS='|' read -r pkg title sec cgi; do
		[ -z "$title" ] && continue
		if [ "$cur_pkg" != "$pkg" ]; then
			if [ "$pkg" = "mod" ]; then
				heading='$(lang de:"Mod-Extras" en:"Mod extras")'
			else
				IFS='|'; set -- $(grep "^$pkg|" "$cgi_reg")
				heading=${2:-$pkg}
			fi

			[ -n "$cur_pkg" ] && echo '</ul>'
			echo "<h1>$heading</h1>"
			echo '<ul>'
			cur_pkg=$pkg
		fi
		echo "<li><a href='$(href extra "$pkg" "$cgi")'>$title</a></li>"
	done
	echo '</ul>'
}

if [ -z "$PATH_INFO" ]; then
	cgi_begin 'Extras' 'extras'

	_cgi_cached extras _cgi_extras

	cgi_end
else
	path_info pkg cgi _
	if ! valid package "$pkg" || ! valid id "$cgi"; then
		cgi_error "Invalid path"
	fi
	IFS='|'
	set -- $(grep "^$pkg|.*|$cgi\$" "$extra_reg")
	IFS=$OIFS

	if [ "$sec_level" -gt "$3" ]; then
		cgi_begin 'Extras'
		echo '<h1>$(lang de:"Zusatz-Skript" en:"Additional script")</h1>'
		echo '<div style="color: #800000;">$(lang de:"Dieses Zusatz-Skript in der aktuellen Sicherheitsstufe nicht verf&uuml;gbar!" en:"This script is not available at the current security level!")</div>'
		echo '<p>'
		back_button --title="$(lang de:"Zu den Extras" en:"Goto extras")" mod extras
		cgi_end
	else
		if [ -x "/mod/usr/lib/cgi-bin/$pkg/$cgi.cgi" ]; then
			/mod/usr/lib/cgi-bin/$pkg/$cgi.cgi
		else
			cgi_error "$(lang de:"Zusatz-Skript '$cgi.cgi' nicht gefunden." en:"Additional script '$cgi.cgi' not found.")"
		fi
	fi
fi
