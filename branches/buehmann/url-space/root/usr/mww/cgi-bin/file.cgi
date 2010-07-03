#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

file_reg=/mod/etc/reg/file.reg
[ -e "$file_reg" ] || touch "$file_reg"

pkg=$(cgi_param pkg | tr -d .)
id=$(cgi_param id | tr -d .)

OIFS=$IFS
IFS='|'
set -- $(grep "^$pkg|$id|" "$file_reg")
IFS=$OIFS
title=$3 sec=$4 def=$5

if [ -z $1 ]; then
	cgi_begin "$(lang de:"Fehler" en:"Error")"
	echo "<p>$(lang
	    de:"Datei '$id' des Pakets '$pkg' ist unbekannt."
	    en:"File '$id' of package '$pkg' is unknown."
	)</p>"
	cgi_end
	exit
fi

cgi_begin "$title" "file:$pkg/$id"

# Defaults
TEXT_ROWS=18

# Load config
[ -r "$def" ] && . "$def"

# Set width
let _width=_cgi_width-230

echo "<h1>$CAPTION</h1>"
[ -n "$DESCRIPTION" ] && echo "<p>$DESCRIPTION</p>"

readonly=false
if [ -z "$CONFIG_FILE" -o "$sec_level" -gt "$sec" ]; then
	readonly=true
	echo '<div style="color: #800000;">$(lang
		de:"Konfiguration in der aktuellen Sicherheitsstufe nicht verf&uuml;gbar!"
		en:"Settings are not available at current security level!"
	)</div>'
fi

case $CONFIG_TYPE in
	text)
		echo "<form action='/freetz/conf/$pkg/$id' method='post'>"
		echo -n "<textarea style='width: ${_width}px;' name='content' rows='$TEXT_ROWS' cols='60' wrap='off' $($readonly && echo "readonly")>"
		[ -r "$CONFIG_FILE" ] && html < "$CONFIG_FILE"
		echo '</textarea>'
		if ! $readonly; then
			echo '<div class="btn"><input type="submit" value="$(lang de:"&Uuml;bernehmen" en:"Apply")"></div>'
		fi
		echo '</form>'
		;;
	list)
		;;
	*)
		echo "<p><b>$(lang de:"Fehler" en:"Error")</b>: $(lang de:"Unbekannter Typ" en:"unknown type") '$CONFIG_TYPE'</p>"
		;;
esac

cgi_end
