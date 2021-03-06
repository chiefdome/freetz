#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin

cgi_width=560
. /usr/lib/libmodcgi.sh

cgi_begin 'Wake on LAN'

cat << EOF
<p>
$(lang de:"Bekannte Hosts" en:"Known hosts"):
<select onChange="var s = this.options[this.options.selectedIndex].value; document.wake.mac.value = s.substr(0,s.search(/\*/)); document.wake.interf.value = s.substr(s.search(/\*/)+1); return false;">
<option value="*" selected>(w&auml;hlen)</option>
EOF

if [ -r "/tmp/flash/exhosts" ]; then
	cat /tmp/flash/exhosts | grep -v "^#" | while read -r ip mac interface host desc; do
		if [ -n "$mac" -a "$mac" != "*" ]; then
			if [ -n "$interface" -a "$interface" != "*" ]; then
				value="$mac*$interface"
			else
				value="$mac*"
			fi

			echo -n '<option value="'"$value"'">'
			if [ -n "$desc" ]; then
				echo -n "$desc"
			elif [ -n "$host" -a "$host" != "*" ]; then 
				echo -n "$host"
			else
				echo -n "$mac"
			fi
			echo '</option>'
		fi
	done
fi

cat << EOF
</select>
</p>
<p>$(lang de:"MAC und Netzwerk-Schnittstelle f&uuml;r Etherwake angeben oder einen der bekannten Hosts w&auml;hlen." en:"Fill in a MAC address and a network interface for etherwake or select a known host from the drop down list above.")</p>
<form style="padding-top: 10px; padding-bottom: 10px;" name="wake" action="/cgi-bin/wake.cgi" method="post">
<table border="0" cellspacing="1" cellpadding="0">
<tr>
<td width="230">MAC: <input type="text" name="mac" size="17" maxlength="17" value=""></td>
<td width="210">Interface: <input type="text" name="interf" size="10" maxlength="10" value=""></td>
<td width="100"><input type="submit" value="WakeUp"></td>
</tr>
</table>
</form>
EOF

cgi_end
