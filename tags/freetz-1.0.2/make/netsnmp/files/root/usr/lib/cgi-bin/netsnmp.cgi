#!/bin/sh
 
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
 
auto_chk=''; man_chk=''
 
if [ "$NETSNMP_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
 
sec_begin '$(lang de:"Starttyp" en:"Start type")'
 
cat << EOF
<p><input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label
for="e1"> $(lang de:"Automatisch" en:"Automatic")</label><input id="e2" type="radio"
name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label></p>
EOF
 
sec_end
sec_begin '$(lang de:"Konfiguration" en:"Configuration")'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=snmpd_conf">$(lang de:"snmpd.conf bearbeiten" en:"Edit snmpd.conf")</a></li>
</ul>
EOF

sec_end
