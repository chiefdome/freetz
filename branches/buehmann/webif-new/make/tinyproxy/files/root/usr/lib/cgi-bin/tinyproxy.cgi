#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$TINYPROXY_ENABLED" yes:auto "*":man
check "$TINYPROXY_CATCHALL" yes:catchall
check "$TINYPROXY_CONFSERVER" yes:confserver


sec_begin 'Starttyp'

cat << EOF
<p>Starttyp<br />
<input id="auto1" type="radio" name="enabled" value="yes"$auto_chk><label for="auto1">Automatisch</label>
<input id="auto2" type="radio" name="enabled" value="no"$man_chk><label for="auto2">Manuell</label>
</p>
EOF

sec_end
sec_begin 'Proxy-Konfiguration'

cat << EOF
<p>Port des Proxyservers: <input id="port" type="text" name="port" value="$(html "$TINYPROXY_PORT")"></p>
<p><input id="catchall1" type="hidden" name="catchall" value="no" />
<input id="catchall2" type="checkbox" name="catchall" value="yes"$catchall_chk><label for="catchall2">Proxy erzwingen</label></p>
EOF

sec_end
sec_begin 'Konfigurationsserver Einstellungen'

cat << EOF
<p>Port des Konfigurationsservers: <input id="confserverport" type="text" name="confserverport" value="$(html "$TINYPROXY_CONFSERVERPORT")"></p>
<p><input id="confserver1" type="hidden" name="confserver" value="no" />
<input id="confserver2" type="checkbox" name="confserver" value="yes"$confserver_chk><label for="confserver2">Konfigurationsserver aktivieren</label></p>
EOF

sec_end
