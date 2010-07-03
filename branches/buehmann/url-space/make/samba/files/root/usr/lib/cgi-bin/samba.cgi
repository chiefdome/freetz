#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$SAMBA_ENABLED" yes:auto inetd "*":man
check "$SAMBA_NMBD_ENABLED" yes:nmbd_auto "*":nmbd_man
check "$SAMBA_MASTER" yes:master

sec_begin '$(lang de:"Starttyp" en:"Start type")'

NMBD=$(which nmbd)
cat << EOF
<p>
EOF
if [ -L "$NMBD" -o -x "$NMBD" ]; then
cat << EOF
$(lang de:"Dateifreigabe (smbd)" en:"Filesharing (smbd) "):&nbsp;
EOF
fi
cat << EOF
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1">$(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2">$(lang de:"Manuell" en:"Manual")</label>
EOF
if [ -e /mod/etc/default.inetd/inetd.cfg ]; then
cat << EOF
<input id="e3" type="radio" name="enabled" value="inetd"$inetd_chk><label for="e3"> $(lang de:"Inetd" en:"Inetd")</label>
EOF
fi
cat << EOF
</p>
EOF

if [ -L "$NMBD" -o -x "$NMBD" ]; then
cat << EOF
<p>
$(lang de:"Namensaufl&ouml;sung (nmbd)" en:"Nameservices (nmbd) "):&nbsp;
<input id="n1" type="radio" name="nmbd_enabled" value="yes"$nmbd_auto_chk><label for="n1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="n2" type="radio" name="nmbd_enabled" value="no"$nmbd_man_chk><label for="n2"> $(lang de:"Manuell" en:"Manual")</label>
EOF
cat << EOF
</p>
EOF
fi

sec_end
sec_begin '$(lang de:"Einstellungen" en:"Settings")'

cat << EOF
<ul>
<li><a href="$(href file samba shares)">$(lang de:"Eigene Freigaben" en:"Shares")</a></li>
<li><a href="$(href file samba sharesx)">$(lang de:"Experten Optionen" en:"Advanced options")</a></li>
</ul>
EOF
if [ -d /var/media/ftp ]; then
cat << EOF
<p>
<font size="-1">$(lang de:"Standard Freigabe(n) bitte im AVM WebIF festlegen:<br />Erweiterte Einstellungen > USB-Ger&auml;te > USB-Speicher" en:"Standard share(s), please specify in AVM WebIF: <br/> Advanced Preferences > USB devices > USB memory")</font>
<br />
<font size="-2">$(lang de:"Optionen: Netzwerkspeicher (an/aus) - Zugriffsberechtigung (rw/ro) - Kennwortschutz (ohne/setzen)" en:"Options: network storage (on / off) - Access Authorization (rw / ro) - Password protection (without / set)")</font>
</p>
EOF
fi

sec_end
sec_begin '$(lang de:"Samba" en:"Samba")'

cat << EOF
<br><p>$(lang de:"Netzwerkschnittstelle" en:"Network interface"):<br>
<input type="text" name="interfaces" size="40" maxlength="255" value="$(html "$SAMBA_INTERFACES")"><br>
<font size="-2">$(lang de:"z.B.: 192.168.178.1/255.255.255.0 oder leer lassen f&uuml;r alle" en:"For example: 192.168.178.1/255.255.255.0 or leave blank for all")</font></P>
<p>$(lang de:"Netbios Name" en:"Netbios Name"): <input type="text" name="netbios_name" size="20" maxlength="255" value="$(html "$SAMBA_NETBIOS_NAME")"></p>
<p>$(lang de:"Arbeitsgruppe" en:"Workgroup"): <input type="text" name="workgroup" size="20" maxlength="255" value="$(html "$SAMBA_WORKGROUP")"></p>
<p>$(lang de:"Beschreibung" en:"Description"):<br><input type="text" name="server_string" size="40" maxlength="255" value="$(html "$SAMBA_SERVER_STRING")"></p>
<p>$(lang de:"OS Level f&uuml;r Election" en:"OS level election"): <input type="text" name="os_level" size="5" maxlength="5" value="$(html "$SAMBA_OS_LEVEL")"></p>
<p>
<input type="hidden" name="master" value="no">
<input id="m1" type="checkbox" name="master" value="yes"$master_chk><label for="m1">$(lang de:"Bevorzugter Master" en:"Preferred Master")</label>
</p>
EOF

sec_end
