#!/bin/sh

PATH=/var/mod/bin:/var/mod/usr/bin:/var/mod/sbin:/var/mod/usr/sbin:/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk='';

case "$DNS2TCP_ENABLED" in yes) auto_chk=' checked';; *) man_chk=' checked';;esac

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"DNS2TCP Daemon" en:"DNS2TCP daemon")'
cat << EOF
<p> $(lang de:"Server binden an UDP Port" en:"Listen on UDP port"): <input type="text" name="port" size="5" maxlength="5" value="$(html "$DNS2TCP_PORT")"></p>
<p style="font-size:10px;">$(lang de:"Bitte beachte: Port 53 ist bereits durch den Fritz.Box DNS Server belegt - nutze einen anderen Port. Damit dieser Tunnel aus dem Internet funktioniert, musst du eine Port-Weiterleitung von UDP Port 53 auf den hier konfigurierten UDP Port einrichten." en:"Please note that port 53 is already used by the Fritz.Box DNS server - use a different port. In order to have the tunnel accessible from the Internet, add a port forwarding rule from UDP port 53 to this configured UDP port.")</p>
<hr>
EOF

cat << EOF
<p style="font-size:10px;">$(lang de:"Eine DNS Domain ist notwendig f&uuml;r die Kommunikation. Es kann auch eine Subdomain sein. Diese Domain muss im Internet aufl&ouml;sbar sein." en:"A DNS domain is necessary for the communication. You can also provide a DNS subdomain. This domain must be known in the Internet.")</p>
<p> $(lang de:"DNS Domain" en:"DNS domain"): <input type="text" name="domain" size="20" maxlength="200" value="$(html "$DNS2TCP_DOMAIN")"></p>
EOF
sec_end

sec_begin '$(lang de:"Hinweise zur Nutzung" en:"Hints for usage")'
cat << EOF
<p style="font-size:10px;">$(lang de:"DNS2TCP ist ein vollst&auml;ndig ungesicherter TCP Tunnel. Derzeit konfiguriert dieses Frontend ausschliesslich einen Tunnel zum Dropbear SSH Port 22 auf der Box - andere Verbindungen m&uuml;ssen manuell konfiguriert werden - dieses Programm erlaubt zu schnell sicherheitskritische Konfigurationen. Bitte bedenke, dass mit diesem Tunnel der Dropbear SSH Daemon im Endeffekt frei im Internet erreichbar ist. Diese Verbindung kann verwendet werden, um eine SOCKSv5 Verbindung zu der Box herzustellen, indem du den OpenSSH Client auf dem Quellrechner nutzt. Folgende Befehle musst du als normaler Benutzer auf deinem Quellrechner nutzen (der erste erstellt den dns2tcp Tunnel welcher am Port 2222 lauscht, der zweite den SOCKSv5 Tunnel durch den dns2tcp Tunnel welcher am Port 1080 lauscht) - der Name dns2tcp.mein.host muss nat&uuml;rlich mit dem oben konfiguierten Namen ersetzt werden:<br><pre>dns2tcpc -r ssh -l 2222 dns2tcp.mein.host dns2tcp.mein.host<br>ssh root@localhost -p 2222 -D 1080</pre>" en:"DNS2TCP is a fully unsecured TCP tunnel. Currently this front end allows the configuration to the Dropbear port 22 on the box only - any other connections must be configured by yourself - this application allows wrong configurations too easily. Please note that with this tunnel the Dropbear SSH daemon is freely reachable from the Internet. This tunnel can be used to establish a SOCKSv5 connection to your box when using the OpenSSH client on your source host. Use the following commands as normal user on your source host (the first establishes the dns2tcp tunnel listening on port 2222, the second establishes the SOCKSv5 tunnel listening on port 1080) - the name dns2tcp.mein.host has to be replaced with the name configured above:<br><pre>dns2tcpc -r ssh -l 2222 dns2tcp.mein.host dns2tcp.mein.host<br>ssh root@localhost -p 2222 -D 1080<br></pre>")</p>
<p style="font-size:10px;">$(lang de:"Um die SOCKS-Verbindung zu verwenden, musst du entweder ein Programm nutzen, welches SOCKSv5 beherrscht, oder du verwendest tsocks, wobei du in /etc/tsocks.conf nur 127.0.0.1 als SOCKS Server eintragen musst. Damit kann jedes Programm mit SOCKS verwendet werden:<br><pre>tsocks PROGRAMMNAME</pre>" en:"To use the SOCKS connection you either have to use an application that can speak SOCKS or you use tsocks. For tsocks, you change in /etc/tsocks.conf that the SOCKSv5 server is 127.0.0.1. With tsocks, every application can be used with SOCKS:<br>tsocks APPLICATIONNAME")</p>
EOF
sec_end
