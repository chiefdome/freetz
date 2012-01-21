#!/bin/sh


. /usr/lib/libmodcgi.sh

stat_button() {
	echo "<form action='/cgi-bin/exec.cgi/$1' method='post'><p><input type='submit' value='$2'></p></form>"
}

cgi --id=system
cgi_begin 'System'

echo "<h1>$(lang de:"Box neustarten" en:"Restart box")</h1>"
stat_button reboot '$(lang de:"Reboot" en:"Reboot")'

echo "<h1>$(lang de:"Nicht unterst&uuml;tzte &Auml;nderungen" en:"Unauthorized changes")</h1>"
cat << EOF
<p>$(lang
	de:"Diese Warnung l&auml;sst sich hier zur&uuml;cksetzen."
	en:"This warning can be reset here."
)</p>
EOF

# stat_button cleanup '$(lang de:"TFFS aufr&auml;umen" en:"Clean up TFFS")'
stat_button fw-attrib '$(lang de:"Warnung zur&uuml;cksetzen" en:"Reset warning")'

cgi_end
