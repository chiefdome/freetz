#!/bin/sh

. /usr/lib/libmodcgi.sh

footer() {
	echo "<p>"

	back_button --title="$(lang de:"Zur&uuml;ck zum Update" en:"Back to update")" mod update

	cgi_end
	touch /tmp/ex_update.done
}
pre_begin() {
	echo "<pre class='log'>"
	exec 3>&2 2>&1
}
pre_end() {
	exec 2>&3 3>&-
	echo "</pre>"
}
html_do() {
	local exit
	eval $({
		{ "$@"; echo exit=$? >&4; } | html
	} 4>&1 >&9)
	return $exit
} 9>&1

do_exit() {
	footer
	exit "$@"
}
status() {
	local status msg=$2
	case $1 in
		"done") status="$(lang de:"ERLEDIGT" en:"DONE")" ;;
		"failed") status="$(lang de:"FEHLGESCHLAGEN" en:"FAILED")" ;;
	esac
	echo -n "<p><span class='status'>$status</span>"
	[ -n "$msg" ] && echo -n " &ndash; $msg"
	echo "</p>"
}

EXTERNAL_FILE=$1
EXTERNAL_TARGET=${NAME%/*}
delete=false
case $NAME in
	*/delete_oldfiles*) delete=true ;;
esac
case $NAME in
	*/external_start*) external_start=true ;;
esac

cgi_begin '$(lang de:"external-Update" en:"external-update")'

echo "<p>$(lang de:"Ziel-Verzeichnis" en:"Target directory"): $EXTERNAL_TARGET</p>"

kill() {
	echo "<h1>$(lang de:"Update vorbereiten" en:"Prepare update")</h1>"
	pre_begin
	echo -n "Stopping external services ... "
	if [ "$(/mod/etc/init.d/rc.external status 2>/dev/null)" == "running" ]; then
		/mod/etc/init.d/rc.external stop >/dev/null
		echo "done."
	else
		echo "not running."
	fi
	if $delete; then
		echo -n "Removing old stuff ... "
		if [ ! -e $EXTERNAL_TARGET/.external ]; then
			echo "$EXTERNAL_TARGET is not an external dir."
		else
			rm -rf "$EXTERNAL_TARGET"
			[ $? -ne 0 ] && echo "failed." || echo "done."
		fi
	else
		echo "Not deleting old external stuff."
	fi
	pre_end
	status "done"
}

[ -d "$EXTERNAL_TARGET" ] && kill

cat << EOF
<h1>$(lang de:"Dateien extrahieren" en:"Extract files")</h1>
EOF

pre_begin
untar() {
	if mkdir -p "$EXTERNAL_TARGET"; then
		if ! tar -C "$EXTERNAL_TARGET" -xv 2>&1; then
			cat > /dev/null # prevent SIGPIPE if tar fails
			return 1
		fi < "$1"
	fi
}

html_do untar "$EXTERNAL_FILE"
result=$?
pre_end
if [ $result -ne 0 ]; then
	status "failed"
	do_exit 1
fi

status "done"

if [ -e /mod/etc/init.d/rc.external ] && $external_start; then
	echo "<h1>$(lang de:"External-Dienste starten" en:"Starting external services")</h1>"
	pre_begin
	/mod/etc/init.d/rc.external start
	pre_end
fi

footer
