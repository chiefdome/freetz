#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$INOTIFY_TOOLS_ENABLED" yes:auto "*":man

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Logdatei" en:"Log file")'

cat << EOF
<p>
<label for="i1">$(lang de:"Dateiname" en:"File name")
<input type="text" name="logfile" size="55" maxlength="250" value="$(html "$INOTIFY_TOOLS_LOGFILE")"></label>
</p>
EOF

sec_end

