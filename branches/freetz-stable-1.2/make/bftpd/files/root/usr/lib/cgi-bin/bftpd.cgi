#!/bin/sh


. /usr/lib/libmodcgi.sh

check "$BFTPD_ENABLED" yes:auto inetd "*":man
check "$BFTPD_ANONYMOUS" yes:anonym

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
EOF
if [ -e "/etc/default.inetd/inetd.cfg" ]; then
cat << EOF
<input id="e3" type="radio" name="enabled" value="inetd"$inetd_chk><label for="e3"> $(lang de:"Inetd" en:"Inetd")</label>
EOF
fi
cat << EOF
</p>
EOF

sec_end
sec_begin '$(lang de:"FTP Server" en:"FTP server")'

cat << EOF
<h2>$(lang de:"Der FTP Server ist gebunden an" en:"The FTP server is listening on"):</h2>
<p>Port: <input type="text" name="port" size="5" maxlength="5" value="$(html "$BFTPD_PORT")"></p>
<h2>$(lang de:"Ports f&uuml;r passives FTP, z.B.: 5000,6000-6100" en:"Port range for passive FTP, e.g. 5000,6000-6100"):</h2>
<p>$(lang de:"Ports" en:"Port range"): <input type="text" name="passive_ports" size="30" maxlength="255" value="$(html "$BFTPD_PASSIVE_PORTS")"></p>
<h2>$(lang de:"Zus&auml;tzliche Kommandozeilen-Optionen (f&uuml;r Experten)" en:"Additional command-line options (for experts)"):</h2>
<p>$(lang de:"Optionen" en:"Options"): <input type="text" name="options" size="20" maxlength="255" value="$(html "$BFTPD_OPTIONS")"></p>
EOF

sec_end
sec_begin '$(lang de:"Zugriff" en:"Access")'

cat << EOF
<p style="font-size:10px;">$(lang de:"Das Passwort f&uuml;r den Benutzer 'ftp' kann mit dem Kommando 'passwd ftp' festgelegt und mit 'modusers save; modsave flash' persistent gespeichert werden." en:"The password for the user 'ftp' can be set by using the command 'passwd ftp' and subsequently saved persistently by 'modusers save; modsave flash'.")</p>
<p>
<input type="hidden" name="anonymous" value="no">
<input id="a1" type="checkbox" name="anonymous" value="yes"$anonym_chk><label for="a1"> $(lang de:"Anonymes FTP" en:"Anonymous FTP")</label>
</p>
EOF

sec_end
