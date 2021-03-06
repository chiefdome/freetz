#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
closed_chck=''; open_chk='';
strict_entry_chck=''; strict_exit_chck='';
relay_enabled_chck='';

if [ "$TOR_ENABLED" == "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$TOR_SOCKS_POLICY_REJECT" == "yes" ]; then closed_chck=' checked'; else open_chk=' checked'; fi
if [ "$TOR_STRICT_ENTRY_NODES" == "yes" ]; then strict_entry_chck=' checked'; fi
if [ "$TOR_STRICT_EXIT_NODES" == "yes" ]; then strict_exit_chck=' checked'; fi
if [ "$TOR_RELAY_ENABLED" == "yes" ]; then relay_enabled_chck=' checked'; fi
if [ "$TOR_DATADIRPERSISTENT" == "yes" ]; then datadirpersistent_enabled_chck=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p><input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label> <input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Einstellungen" en:"Configuration")'

cat << EOF
<h2>$(lang de:"Der Tor Server ist gebunden an" en:"The Tor server is listening on")</h2>
<p>$(lang de:"IP Adresse" en:"IP Address"):&nbsp;<input id="address" type="text" size="16" maxlength="16" name="socks_address" value="$(html "$TOR_SOCKS_ADDRESS")">   
$(lang de:"Port" en:"Port"):&nbsp;<input id="port" type="text" size="5" maxlength="5" name="socks_port" value="$(html "$TOR_SOCKS_PORT")"></p>
<h2>$(lang de:"Fernsteuerung" en:"Remote Control") (optional)</h2>
<p>Control Port:&nbsp;<input id="control" type="text" size="5" maxlength="5" name="control_port" value="$(html "$TOR_CONTROL_PORT")"></p>
<p>$(lang de:"Zeitlimit f&uuml;r Tor-Verbindungen" en:"Circuit Idle Timeout") (optional):&nbsp;<input id="idle_timeout" type="text" size="5" maxlength="5" name="circuit_idle_timeout" value="$(html "$TOR_CIRCUIT_IDLE_TIMEOUT")"></p>
EOF

sec_end
sec_begin '$(lang de:"Zugriffskontrolle" en:"Access Control")'

cat << EOF
<p>$(lang de:"Erlaubte Clients" en:"Allowed clients"): <input id="e4" type="radio" name="socks_policy_reject" value="no"$open_chk><label for="e4"> $(lang de:"alle" en:"all")</label> <input id="e3" type="radio" name="socks_policy_reject" value="yes"$closed_chck><label for="e3"> $(lang de:"eingeschr&auml;nkt" en:"restricted")</label></p>
<h2>$(lang de:"Liste mit IP-Adressen (eine pro Zeile)" en:"List of IP-Addresses (one per line)")</h2>
<p><textarea id="accept" name="socks_policy_accept" rows="4" cols="50" maxlength="255">$(html "$TOR_SOCKS_POLICY_ACCEPT")</textarea><br />
Syntax: &lt;addr&gt;[/&lt;mask&gt;]<br />
<span style="font-size:10px;">$(lang de:"Um alle lokal verbundenen Netzwerke zu erlauben, kann man den Alias <i>private</i> anstelle einer Adresse eintragen" en:"To specify all internal and link-local networks, you can use the <i>private</i> alias instead of an address").</span>
</p>
EOF

sec_end
sec_begin '$(lang de:"Eingangs- und Ausgangsserver" en:"Entrynodes and Exitnodes")'

cat << EOF
<h2>$(lang de:"Liste mit Tor Servern (einer pro Zeile)" en:"List of Tor servers (one per line)")</h2>
<p><textarea id="accept" name="entry_nodes" rows="4" cols="50" maxlength="255">$(html "$TOR_ENTRY_NODES")</textarea></p>
<p>$(lang de:"Nur diese Server als Eingang verwenden" en:"Only use these servers as entry nodes"): <input type="hidden" name="strict_entry_nodes" value="no"><input id="e6" type="checkbox" name="strict_entry_nodes" value="yes"$strict_entry_chck></p>
<h2>$(lang de:"Liste mit Tor Servern (einer pro Zeile)" en:"List of Tor servers (one per line)")</h2>
<p><textarea id="accept" name="exit_nodes" rows="4" cols="50" maxlength="255">$(html "$TOR_EXIT_NODES")</textarea></p>
<p>$(lang de:"Nur diese Server als Ausgang verwenden" en:"Only use these servers as exit nodes"): <input type="hidden" name="strict_exit_nodes" value="no"><input id="e7" type="checkbox" name="strict_exit_nodes" value="yes"$strict_exit_chck></p>
EOF

sec_end
sec_begin '$(lang de:"Tor als Relay (Node) konfigurieren" en:"Relay (node) configuration")'

cat << EOF
<p>$(lang de:"Tor auch als Server starten" en:"Open tor relay"): <input type="hidden" name="relay_enabled" value="no"><input id="e8" type="checkbox" name="relay_enabled" value="yes"$relay_enabled_chck></p>
<p>$(lang de:"Nickname des Servers" en:"Nickname"):&nbsp;<input id="nick" type="text" size="16" maxlength="16" name="nickname" value="$(html "$TOR_NICKNAME")")></p>
<p>$(lang de:"IP oder FQDN des Servers" en:"IP or FQDN for your server"):&nbsp;<input id="address" type="text" size="30" maxlength="30" name="address" value="$(html "$TOR_ADDRESS")")></p>
<p>BandwidthRate ($(lang de:"z.B." en:"e.g.") "20 KB"):&nbsp;<input id="bandwith" type="text" size="5" maxlength="5" name="bandwidthrate" value="$(html "$TOR_BANDWIDTHRATE")"></p>
<p>BandwidthBurst ($(lang de:"z.B." en:"e.g.") "40 KB"):&nbsp;<input id="bandwithburst" type="text" size="5" maxlength="5" name="bandwidthburst" value="$(html "$TOR_BANDWIDTHBURST")"></p>
<p>ORPort:&nbsp;<input id="or" type="text" size="5" maxlength="5" name="orport" value="$(html "$TOR_ORPORT")"> &nbsp; DirPort:&nbsp;<input id="dir" type="text" size="5" maxlength="5" name="dirport" value="$(html "$TOR_DIRPORT")"> 
&nbsp;<i> $(lang de:"Lokale Portfreigaben einrichten" en:"Open local ports"): <a href="/cgi-bin/pkgconf.cgi?pkg=avm-firewall">$(lang de:"hier klicken" en:"click here")</a></i></p>
<p>MaxOnionsPending (Default 100): &nbsp;<input id="maxonions" type="text" size="5" maxlength="5" name="maxonionspending" value="$(html "$TOR_MAXONIONSPENDING")"></p>
<p>ExitPolicy ($(lang de:"z.B." en:"e.g.") "reject *.*" = no exits allowed):&nbsp;<input id="policy" type="text" size="20" maxlength="20" name="exitpolicy" value="$(html "$TOR_EXITPOLICY")"></p>
<a href="/cgi-bin/file.cgi?id=secret_id_key">$(lang de:"Secret ID Key bearbeiten" en:"Edit secret ID key")</a>
<p>DataDirectory (Default /var/tmp/tor): &nbsp;<input id="datadir" type="text" size="40" maxlength="40" name="datadirectory" 
value="$(html "$TOR_DATADIRECTORY")"> &nbsp; 
$(lang de:"Verzeichnis" en:"directory") persistent: <input type="hidden" name="datadirpersistent" value="no"><input id="e9" type="checkbox" name="datadirpersistent" value="yes"$datadirpersistent_enabled_chck></p>
</p>

EOF

sec_end
