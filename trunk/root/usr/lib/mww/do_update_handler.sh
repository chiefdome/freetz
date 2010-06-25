#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/mod/sbin:/mod/bin:/mod/usr/sbin:/mod/usr/bin
. /usr/lib/libmodcgi.sh

exec 1> /tmp/fw_update.log 2>&1
indent() {
	sed 's/^/  /' | html
}
pre_exit() {
	echo "</pre>"
	exit "$@"
}
echo "<pre>"

stop=${NAME%/*}
downgrade=false
case $NAME in
    */downgrade) downgrade=true ;;
esac

if $downgrade; then
	echo "$(lang
	    de:"Downgrade vorbereiten"
	    en:"Prepare downgrade"
	) ..."
	/usr/bin/prepare-downgrade | indent
	echo "$(lang de:"ERLEDIGT" en:"DONE")"
	echo "</pre><pre>"
fi

if [ "$stop" = stop_avm ]; then
	echo "$(lang
	    de:"AVM-Dienste anhalten, Teil 1"
	    en:"Stopping AVM services, part 1"
	) (prepare_fwupgrade start) ..."
	prepare_fwupgrade start 2>&1 | indent
	echo "$(lang de:"ERLEDIGT" en:"DONE")"
	echo "</pre><pre>"
fi

if [ "$stop" = semistop_avm ]; then
	echo "$(lang
	    de:"AVM-Dienste teilweise anhalten, Teil 1"
	    en:"Stopping AVM services partially, part 1"
	) (prepare_fwupgrade start_from_internet) ..."
	prepare_fwupgrade start_from_internet 2>&1 | indent
	echo "$(lang de:"ERLEDIGT" en:"DONE")"
	echo "</pre><pre>"
fi

echo "$(lang de:"Firmware-Archiv extrahieren" en:"Extracting firmware archive") ..."
tar_log=$(tar -f "$1" -C / -xv 2>&1)
result=$?
echo "$tar_log" | indent
if [ $result -ne 0 ]; then
	echo "$(lang de:"FEHLGESCHLAGEN" en:"FAILED")"
	pre_exit 1
fi
echo "$(lang de:"ERLEDIGT" en:"DONE")"

if [ "$stop" != nostop_avm ]; then
	echo "</pre><pre>"
	echo "$(lang
	    de:"AVM-Dienste anhalten, Teil 2"
	    en:"Stopping AVM services, part 2"
	) (prepare_fwupgrade end) ..."
	prepare_fwupgrade end 2>&1 | indent
	echo "$(lang de:"ERLEDIGT" en:"DONE")"
fi

[ "$stop" = semistop_avm ] && ( sleep 30; reboot )&

cat << EOF
</pre><pre>
$(lang
    de:"Ausf�hren des Firmware-Installationsskripts"
    en:"Executing firmware installation script"
) /var/install ...
EOF
if [ ! -x /var/install ]; then
	cat << EOF
$(lang
    de:"FEHLGESCHLAGEN - Installationsskript nicht gefunden oder nicht ausf�hrbar.

Weiter ohne Neustart.
Sie sollten bei Bedarf noch die extrahierten Dateien l�schen."
    en:"FAILED - installation script not found or not executable.

Resuming without reboot.
You may want to clean up the extracted files."
)
EOF
	pre_exit 1
fi
# Remove no-op original from var.tar
rm -f /var/post_install
inst_log=$(/var/install 2>&1)
result=$?
echo "$inst_log" | indent
unset inst_log
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
echo "$(lang
    de:"ERLEDIGT - R�ckgabewert des Installationsskripts"
    en:"DONE - installation script return code"
) = $result ($result_txt)"

echo "</pre><pre>"
echo "$(lang de:"Von" en:"Generated content of") /var/post_install$(lang de:" generierter Inhalt:" en:":")"
if [ ! -x /var/post_install ]; then
	echo "$(lang de:"KEINER - Nach-Installationsskript nicht gefunden oder nicht ausf�hrbar." en:"NONE - post-installation script not found or not executable.")"
	pre_exit 1
fi
indent < /var/post_install
cat << EOF
$(lang de:"ENDE DER DATEI" en:"END OF FILE")
</pre>

<p>
$(lang
    de:"Das Nach-Installationsskript l�uft beim Neustart (reboot) und f�hrt die
darin definierten Aktionen aus, z.B. das tats�chliche Flashen der Firmware.
Sie k�nnen immer noch entscheiden, diesen Vorgang abzubrechen, indem Sie
das Skript und den Rest der extrahierten Firmware-Komponenten l�schen."
    en:"The post-installation script will be executed upon reboot and perform
the actions specified therein, e.g. the actual firmware flashing.
You may still choose to interrupt this process by removing the script
along with the rest of the extracted firmware components."
)
</p>
EOF
