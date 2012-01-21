#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$HIAWATHA_ENABLED" yes:auto "*":man
check "$HIAWATHA_FASTCGI" yes:fastcgi

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"Web Server" en:"Web server")'
cat << EOF
<table>
<p>$(lang de:"Port" en:"Port"): <input type="text" name="port" size="5" maxlength="5" value="$(html "$HIAWATHA_PORT")"></p>
<p>$(lang de:"Interface" en:"Interface"): <input type="text" name="interface" size="20" maxlength="255" value="$(html "$HIAWATHA_INTERFACE")"></p>
<p>$(lang de:"Website root" en:"Website root"): <input type="text" name="websiteroot" size="30" maxlength="255" value="$(html "$HIAWATHA_WEBSITEROOT")"></p>
<p>$(lang de:"Host name" en:"Host name"): <input type="text" name="hostname" size="20" maxlength="255" value="$(html "$HIAWATHA_HOSTNAME")"></p>
<p>$(lang de:"Log directory" en:"Log directory"): <input type="text" name="logdir" size="30" maxlength="255" value="$(html "$HIAWATHA_LOGDIR")"></p>
<p><input type="hidden" name="fastcgi" value="no">
<label for="f1">$(lang de:"FastCGI" en:"FastCGI"): </label><input id="f1" type="checkbox" name="fastcgi" value="yes"$fastcgi_chk></p>
</table>
EOF
sec_end
