#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$AUTOFS_ENABLED" yes:auto "*":man
check "$AUTOFS_DAVFS2_CONF" yes:davfs2_conf
check "$AUTOFS_EXTERNAL" yes:external

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"Konfiguration" en:"Configuration")'
cat << EOF
<h2>$(lang de:"Optionale Aufrufparameter:" en:"Optional commandline parameters:")</h2>
<p><input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$AUTOFS_CMDLINE")"></p>
EOF
if [ -r /etc/external.pkg ]; then
cat << EOF
<p>
<input type="hidden" name="external" value="no">
<input id="e1" type="checkbox" name="external" value="yes"$external_chk><label for="e1">$(lang de:"<a href=/cgi-bin/conf/mod#external>External</a> zusammen mit autofs starten/stoppen" en:"Start/stop <a href=/cgi-bin/conf/mod#external>external</a> with autofs")</label>
</p>
EOF
fi
sec_end

if which mount.davfs >/dev/null; then
sec_begin '$(lang de:"Dateisysteme" en:"Filesystems")'
cat << EOF
<p>
<input type="hidden" name="davfs2_conf" value="no">
<input id="d1" type="checkbox" name="davfs2_conf" value="yes"$davfs2_conf_chk><label for="d1">$(lang de:"davfs2 konfigurieren" en:"configure davfs2")</label>
</p>
<h2>$(lang de:"Verzeichnis f&uuml;r den Cache von davfs2" en:"Directory for davfs2's cache"):</h2>
<p><input type="text" name="davfs2_temp" size="55" maxlength="250" value="$(html "$AUTOFS_DAVFS2_TEMP")"></p>
EOF
sec_end
fi
