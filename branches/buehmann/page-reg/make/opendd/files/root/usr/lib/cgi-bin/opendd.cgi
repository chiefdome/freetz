#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$OPENDD_ENABLED" yes:auto "*":man
check "$OPENDD_FORCE_UPDATE" yes:force_update

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="auto" type="radio" name="enabled" value="yes"$auto_chk><label for="auto"> $(lang de:"Aktiviert" en:"Enabled")</label>
<input id="manual" type="radio" name="enabled" value="no"$man_chk><label for="manual"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</p>
<font size="1">
$(lang de:"OpenDD aktualisiert die dynamischen DNS-Adressen nach einem IP-Wechsel automatisch und l&auml;uft nicht als Dienst." en:"OpenDD updates the dynamic dns addresses automatically after an IP change and doesn't need to run as a daemon.")
</font>
EOF

sec_end
sec_begin '$(lang de:"Optionen" en:"Options")'

cat << EOF
<p>
<input type="hidden" name="force_update" value="no">
<input id="u1" type="checkbox" name="force_update" value="yes"$force_update_chk><label for="u1">$(lang de:"Sp&auml;testens nach 25 Tagen updaten (hierfür sollte crond noch aktiviert sein)." en:"Force update after 25 days (you should also enable crond).")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Konfigurationsdatei" en:"Configuration file")'

cat << EOF
<p>
<textarea id="config" name="config" rows="30" cols="80" wrap="off">$(html "$OPENDD_CONFIG")</textarea>
</p>
EOF

sec_end

