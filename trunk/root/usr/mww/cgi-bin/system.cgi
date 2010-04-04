#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

stat_button() {
	echo '<div class="btn"><form class="btn" action="/cgi-bin/exec.cgi" method="post"><input type="hidden" name="cmd" value="'"$1"'"><input type="submit" value="'"$2"'"></form></div>'
}

cgi_begin 'System' system

cat << EOF
<h1>"$(lang de:"Nicht unterst�tzte �nderungen" en:"Unauthorized changes")"</h1>

<p>$(lang
    de:"Diese Warnung l�sst sich hier zur�cksetzen."
    en:"This warning can be reset here."
)</p>
EOF

# stat_button cleanup '$(lang de:"TFFS aufr�umen" en:"Clean up TFFS")'
stat_button fw_attrib '$(lang de:"Warnung zur�cksetzen" en:"Reset warning")'

cgi_end
