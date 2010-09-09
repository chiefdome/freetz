if ! [ -r "/mod/etc/default.$PACKAGE/$PACKAGE.cfg" \
	-o -r "/mod/etc/default.$PACKAGE/$PACKAGE.save" ]; then
	cgi --id="conf:$PACKAGE"
	cgi_error "$(lang
		de:"Das Paket '$PACKAGE' ist nicht konfigurierbar."
		en:"the package '$PACKAGE' is not configurable."
	)"
	exit
fi

# retrieve metadata
PKG_REG=/mod/etc/reg/pkg.reg
[ -e "$PKG_REG" ] || touch "$PKG_REG"

if [ "$PACKAGE" = mod ]; then
	PACKAGE_TITLE='$(lang de:"Einstellungen" en:"Settings")'
else
	OIFS=$IFS; IFS="|"
	set -- $(grep "^$PACKAGE|" "$PKG_REG")
	IFS=$OIFS
	PACKAGE_TITLE=${2:-$PACKAGE}
fi

[ -z "$ID" ] && ID=_index

help="/packages/$PACKAGE"
[ "$ID" = _index ] || help="$help/$ID"

cgi --id="conf:$PACKAGE/$ID" --help="$help" --style=mod/daemons.css

case $REQUEST_METHOD in
	POST)   source "${HANDLER_DIR}/save.sh" ;;
	GET|*)  source "${HANDLER_DIR}/edit.sh" ;;
esac
