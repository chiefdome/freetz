#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
pwdauth_yes_chk=''; pwdauth_no_chk=''; rootonly_yes_chk=''; rootonly_no_chk=''

case "$DROPBEAR_ENABLED" in yes) auto_chk=' checked';; inetd) inetd_chk=' checked';; *) man_chk=' checked';;esac
if [ "$DROPBEAR_PWDAUTH" = "yes" ]; then pwdauth_yes_chk=' checked'; else pwdauth_no_chk=' checked'; fi
if [ "$DROPBEAR_ROOTONLY" = "yes" ]; then rootonly_yes_chk=' checked'; else rootonly_no_chk=' checked'; fi

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
sec_begin '$(lang de:"Host-based Authentication" en:"Host-based authentication")'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=authorized_keys">$(lang de:"Authorized keys bearbeiten" en:"Edit authorized keys")</a></li>
</ul>
EOF

sec_end
sec_begin '$(lang de:"SSH Server" en:"SSH server")'

cat << EOF
<h2>$(lang de:"Der SSH Server ist gebunden an" en:"The SSH server is listening on"):</h2>
<p>Port: <input type="text" name="port" size="5" maxlength="5" value="$(html "$DROPBEAR_PORT")"></p>
<h2>$(lang de:"Passwort Login" en:"Password login"):</h2>
<p>
<input id="p1" type="radio" name="pwdauth" value="yes"$pwdauth_yes_chk><label for="p1"> $(lang de:"Aktiviert" en:"Enabled")</label>
<input id="p2" type="radio" name="pwdauth" value="no"$pwdauth_no_chk><label for="p2"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</p>
<h2>$(lang de:"Login nur f&uuml;r root erlauben" en:"Allow only root login"):</h2>
<p>
<input id="r1" type="radio" name="rootonly" value="yes"$rootonly_yes_chk><label for="r1"> $(lang de:"Aktiviert" en:"Enabled")</label>
<input id="r2" type="radio" name="rootonly" value="no"$rootonly_no_chk><label for="r2"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</p>
<p style="font-size:10px;">$(lang de:"Bitte beachte, dass die FRITZ!Box kein ad&auml;quates Benutzermanagement bietet. Die Dateien /etc/passwd und /etc/shadow werden bei jedem Boot neu angelegt. Bitte aktiviere die Unterst&uuml;tzung f&uuml;r normale Benutzer nur, wenn Du genau wei&szlig;t, was Du tust." en:"Please note that the FRITZ!Box does not support normal user management. The files /etc/passwd and /etc/shadow are re-created during each boot. Please activate the support for regular users only if you know what you are doing.")</p>
<h2>$(lang de:"Zus&auml;tzliche Kommandozeilen-Optionen (f&uuml;r Experten)" en:"Additional command-line options (for experts)"):</h2>
<p>$(lang de:"Optionen" en:"Options"): <input type="text" name="options" size="20" maxlength="255" value="$(html "$DROPBEAR_OPTIONS")"></p>
EOF

sec_end
