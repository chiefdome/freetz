#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$HTTPRY_ENABLED"  yes:auto "*":man

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"Konfiguration und Filter" en:"Configuration and filter")'
cat << EOF
<p>
$(lang de:"Parameter (au&szlig;er -d -u -o -i): " en:"Parameters (except -d -u -o -i): ")
<input type="text" name="cmdline" size="95" maxlength="250" value="$(html "$HTTPRY_CMDLINE")">
</p>
<p>
$(lang de:"Logdatei: " en:"Log file: ")
<input type="text" name="logfile" size="95" maxlength="250" value="$(html "$HTTPRY_LOGFILE")">
</p>
<p>
$(lang de:"Interface: " en:"Interface: ")
<input type="text" name="interface" size="95" maxlength="250" value="$(html "$HTTPRY_INTERFACE")">
</p>
<p>
<a target="_blank" href="http://www.nwlab.net/tutorials/wireshark/wireshark-tutorial-4.html#teil4">$(lang de:"Capture Filter" en:"Capture filter")</a>:&nbsp;
<input type="text" name="capfilter" size="95" maxlength="250" value="$(html "$HTTPRY_CAPFILTER")">
</p>
EOF
sec_end

sec_begin '$(lang de:"Hilfe" en:"Help")'
cat << EOF
<p>
<textarea id="help" " name="config" rows="20" cols="90" wrap="off">$(html "$(httpry -h)")</textarea>
</p>
EOF
sec_end
