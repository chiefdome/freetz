#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/mod/sbin:/mod/bin:/mod/usr/sbin:/mod/usr/bin
. /usr/lib/libmodcgi.sh

footer() {
	echo "<p>"

	back_button --title="$(lang de:"Zur&uuml;ck zur &Uuml;bersicht" en:"Back to main page")" mod status

	cat << EOF
<form action="/cgi-bin/exec.cgi/reboot" method="post"><div class="btn"><input type="submit" value="Reboot"></div></form>
</p>
EOF

	cgi_end
	touch /tmp/fw_update.done
}
pre_begin() {
	echo "<pre class='log'>"
	exec 3>&2 2>&1
}
pre_end() {
	exec 2>&3 3>&-
	echo "</pre>"
}
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

cgi_begin '$(lang de:"Firmware-Update" en:"Firmware update")'

cat << EOF
<h1>$(lang
	de:"Firmware extrahieren, Update vorbereiten"
	en:"Extract firmware, prepare update"
)</h1>
EOF

stop=${NAME%/*}
downgrade=false
case $NAME in
	*/downgrade) downgrade=true ;;
esac

if $downgrade; then
	echo "<p>$(lang
		de:"Downgrade vorbereiten"
		en:"Prepare downgrade"
	) ...</p>"
	pre_begin
	/usr/bin/prepare-downgrade
	pre_end
	status "done"
fi

if [ "$stop" = stop_avm ]; then
	echo "<p>$(lang
		de:"AVM-Dienste anhalten, Teil 1"
		en:"Stopping AVM services, part 1"
	) (prepare_fwupgrade start) ...</p>"
	pre_begin
	prepare_fwupgrade start 2>&1
	pre_end
	status "done"
fi

if [ "$stop" = semistop_avm ]; then
	echo "<p>$(lang
		de:"AVM-Dienste teilweise anhalten, Teil 1"
		en:"Stopping AVM services partially, part 1"
	) (prepare_fwupgrade start_from_internet) ...</p>"
	pre_begin
	prepare_fwupgrade start_from_internet 2>&1
	pre_end
	status "done"
fi

echo "<p>$(lang
	de:"Firmware-Archiv extrahieren"
	en:"Extracting firmware archive"
) ...</p>"
pre_begin
tar -f "$1" -C / -xv 2>&1
result=$?
pre_end
if [ $result -ne 0 ]; then
	status "failed"
	do_exit 1
fi
status "done"

if [ "$stop" != nostop_avm ]; then
	echo "<p>$(lang
		de:"AVM-Dienste anhalten, Teil 2"
		en:"Stopping AVM services, part 2"
	) (prepare_fwupgrade end) ...</p>"
	pre_begin
	prepare_fwupgrade end 2>&1
	pre_end
	status "done"
fi

[ "$stop" = semistop_avm ] && ( sleep 30; reboot )&

cat << EOF
<p>$(lang
	de:"Ausf�hren des Firmware-Installationsskripts"
	en:"Executing firmware installation script"
) /var/install ...</p>
EOF
if [ ! -x /var/install ]; then
	status "failed" "$(lang
		de:"Installationsskript nicht gefunden oder nicht ausf�hrbar."
		en:"Installation script not found or not executable."
	)"
	cat << EOF
<p>$(lang 
	de:"Weiter ohne Neustart. Sie sollten bei Bedarf noch die extrahierten
	Dateien l�schen."
	en:"Resuming without reboot. You may want to clean up the extracted
	files."
)</p>
EOF
	do_exit 1
fi

pre_begin
# Remove no-op original from var.tar
rm -f /var/post_install
/var/install 2>&1
result=$?
pre_end

case $result in
	0) result_txt="INSTALL_SUCCESS_NO_REBOOT" ;;
	1) result_txt="INSTALL_SUCCESS_REBOOT" ;;
	2) result_txt="INSTALL_WRONG_HARDWARE" ;;
	3) result_txt="INSTALL_KERNEL_CHECKSUM" ;;
	4) result_txt="INSTALL_FILESYSTEM_CHECKSUM" ;;
	5) result_txt="INSTALL_URLADER_CHECKSUM" ;;
	6) result_txt="INSTALL_OTHER_ERROR" ;;
	7) result_txt="INSTALL_FIRMWARE_VERSION" ;;
	8) result_txt="INSTALL_DOWNGRADE_NEEDED" ;;
	*) result_txt="$(lang de:"unbekannter Fehlercode" en:"unknown error code")" ;;
esac

status "done" "$(lang
    de:"R�ckgabewert des Installationsskripts"
    en:"Installation script return code"
): $result ($result_txt)"

echo "<p>$(lang de:"Von" en:"Generated content of") /var/post_install$(lang de:" generierter Inhalt:" en:":")</p>"
if [ ! -x /var/post_install ]; then
	print_error "$(lang 
		de:"Nach-Installationsskript nicht gefunden oder nicht ausf�hrbar." 
		en:"Post-installation script not found or not executable."
	)"
	pre_end
	do_exit 1
fi
pre_begin
cat /var/post_install
pre_end

cat << EOF
<p>
$(lang
	de:"Das Nach-Installationsskript l�uft beim Neustart (reboot) und f�hrt
die darin definierten Aktionen aus, z.B. das tats�chliche Flashen der Firmware.
Sie k�nnen immer noch entscheiden, diesen Vorgang abzubrechen, indem Sie das
Skript und den Rest der extrahierten Firmware-Komponenten l�schen."
	en:"The post-installation script will be executed upon reboot and
perform the actions specified therein, e.g. the actual firmware flashing.  You
may still choose to interrupt this process by removing the script along with
the rest of the extracted firmware components."
)
</p>
EOF

footer
