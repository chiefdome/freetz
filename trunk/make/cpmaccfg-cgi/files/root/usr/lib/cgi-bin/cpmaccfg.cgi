#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
pwdauth_yes_chk=''; pwdauth_no_chk=''

case "$CPMACCFG_ENABLED" in yes) auto_chk=' checked';; inetd) inetd_chk=' checked';; *) man_chk=' checked';;esac

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> Auto</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> Manual</label>
EOF
cat << EOF
</p>
EOF

sec_end
sec_begin 'Port Status'

cat << EOF
<br>
<p><center>
<table background="../images/avm-hinten.jpg" width="468" height="89" cellpadding="0" border="0">
<tr><td width="150">&nbsp;</td><td width="318">
<table border="0" cellspacing="4" cellpadding="4" style="border: 1px solid black;background-color:#9A9C91" align="center">
<tr>
<td>&nbsp</td>
EOF

# Link-Farbe und Anzahl External Ports bestimmen
LINK="green"
EXTPORTS=$(/mod/sbin/cpmaccfg info|grep "External"|awk '{print $3}')

# Ports Anzeigen
row=1
while [ $row -le $EXTPORTS ]; do
	COLOR="darkred"
	PORT="$(/mod/sbin/cpmaccfg gpme $row|sed -e "s/.*: //g")"
	if [ "$PORT" != "no link" ]; then COLOR=$LINK;fi
	echo -n '<td align="center" style="border: 1px solid black;background-color:'$COLOR';color:white;width:20px;"><b>'$row'</b></td>'
	row=$(($row+1))
done

cat << EOF
</tr>
</table>
</td></tr>
</table>
</center>
<br/></p>

<table border="1" cellpadding="1" cellspacing="1" width="100%">
<tr>
<th>Port</th><th>Mode</th><th>VLAN</th><th align="left">Port Media</th>
</tr>
EOF

# Portstatus anzeigen
row=1
while [ $row -le $EXTPORTS ]; do
	echo -n '<tr><td align="center">'$row'</td><td align="center">'
	echo -n $(/mod/sbin/cpmaccfg gpm|grep $row|awk '{print $3}')
	VLAN="$(cat /mod/etc/conf/cpmaccfg.cfg |grep "VLAN"$row|sed -e "s/.*VLAN$row='//g"|sed -e "s/'//g")"
	if [ $VLAN = "eth0" ];then COLOR="lightblue"; fi
	if [ $VLAN = "eth1" ];then COLOR="lightgreen"; fi
	if [ $VLAN = "eth2" ];then COLOR="lightcyan"; fi
	if [ $VLAN = "eth3" ];then COLOR="lightyellow"; fi
	echo -n '</td><td align="center" bgcolor="'$COLOR'">'
	echo -n $VLAN
	echo -n '</td><td align="left">'
	echo -n $(/mod/sbin/cpmaccfg gpme $row|sed -e "s/.*: //g")
	echo -n '</td></tr>'
	row=$(($row+1))
done

cat << EOF
</table>
<font size="1">save = auto-detect</font>
EOF

sec_end

sec_begin 'Port Settings'

cat << EOF
<p>
<table border="0" width="100%">
<tr>
<td align="center">LAN Port</td><td align="center">Mode</td><td align="center">VLAN</td><td align="center">Speed</td><td align="center">Flow Control</td>
</tr>

EOF

# Dropdown f�r Einstellungen anzeigen
row=1
while [ $row -le $EXTPORTS ]; do
	echo -n '<tr><td align="center">Port '$row'</td>'
	echo -n '<td align="center"><select name="mode'$row'"><option selected>'
	echo -n $(cat /mod/etc/conf/cpmaccfg.cfg |grep "MODE"$row|sed -e "s/.*MODE$row='//g"|sed -e "s/'//g")
	echo -n '<option value="on">on</option><option value="off">off</option><option value="save">save</option></select></td>'
	echo -n '<td align="center"><select name="vlan'$row'"><option selected>'
	echo -n $(cat /mod/etc/conf/cpmaccfg.cfg |grep "VLAN"$row|sed -e "s/.*VLAN$row='//g"|sed -e "s/'//g")
	echo -n '<option value="eth0">eth0</option><option value="eth1">eth1</option><option value="eth2">eth2</option><option value="eth3">eth3</option></select></td>'
	echo -n '<td align="center"><select name="speed'$row'"><option selected>'
	echo -n $(cat /mod/etc/conf/cpmaccfg.cfg |grep "SPEED"$row|sed -e "s/.*SPEED$row='//g"|sed -e "s/'//g")
	echo -n '<option value="auto">auto</option><option value="10baseT-HD">10baseT-HD</option><option value="10baseT-FD">10baseT-FD</option><option value="100baseTx-HD">100baseTx-HD</option><option value="100baseTx-FD">100baseTx-FD</option></select></td>'
	echo -n '<td align="center"><select name="flow'$row'"><option selected>'
	echo -n $(cat /mod/etc/conf/cpmaccfg.cfg |grep "FLOW"$row|sed -e "s/.*FLOW$row='//g"|sed -e "s/'//g")
	echo -n '<option value="enable">enable</option><option value="disable">disable</option></select></td></tr>'
row=$(($row+1))
done

cat << EOF
</table>
<hr>
<table>
<tr>
<td align="center">WLAN group:</td><td align="center"><select name="wlan"><option selected>$(html "$CPMACCFG_WLAN")
<option value="eth0">eth0</option><option value="eth1">eth1</option><option value="eth2">eth2</option><option value="eth3">eth3</option></select></td>
<td> Please choose the assignment for wireless LAN</td>
</tr>
</table>
</p>

EOF
sec_end

SetToNull=''
sec_begin 'Advanced VLAN/IP Settings'

if [ $CPMACCFG_VLAN2 = "eth1" -o $CPMACCFG_VLAN2 = "eth1" -o $CPMACCFG_VLAN3 = "eth1" -o $CPMACCFG_VLAN4 = "eth1" ]; then
	echo -n '<p>IP eth1: <input type="text" name="eth1_ip" value="'$(html "$CPMACCFG_ETH1_IP")'">'
	echo -n ' Subnet: <input type="text" name="eth1_subnet" value="'$(html "$CPMACCFG_ETH1_SUBNET")'">'
	echo -n '</p>'
else
	SetToNull=$SetToNull'<input type="hidden" name="eth1_ip" value="">'   
fi

if [ $CPMACCFG_VLAN2 = "eth2" -o $CPMACCFG_VLAN2 = "eth2" -o $CPMACCFG_VLAN3 = "eth2" -o $CPMACCFG_VLAN4 = "eth2" ]; then
	echo -n '<p>IP eth2: <input type="text" name="eth2_ip" value="'$(html "$CPMACCFG_ETH2_IP")'">'
	echo -n ' Subnet: <input type="text" name="eth2_subnet" value="'$(html "$CPMACCFG_ETH2_SUBNET")'">'
	echo -n '</p>'
else
	SetToNull=$SetToNull'<input type="hidden" name="eth2_ip" value="">'
fi

if [ $CPMACCFG_VLAN2 = "eth3" -o $CPMACCFG_VLAN2 = "eth3" -o $CPMACCFG_VLAN3 = "eth3" -o $CPMACCFG_VLAN4 = "eth3" ]; then
	echo -n '<p>IP eth1: <input type="text" name="eth3_ip" value="'$(html "$CPMACCFG_ETH3_IP")'">'
	echo -n ' Subnet: <input type="text" name="eth3_subnet" value="'$(html "$CPMACCFG_ETH3_SUBNET")'">'
	echo -n '</p>'
else
	SetToNull=$SetToNull'<input type="hidden" name="eth3_ip" value="">'
fi

if [ $CPMACCFG_VLAN2 = "eth4" -o $CPMACCFG_VLAN2 = "eth4" -o $CPMACCFG_VLAN3 = "eth4" -o $CPMACCFG_VLAN4 = "eth4" ]; then
	echo -n '<p>IP eth1: <input type="text" name="eth4_ip" value="'$(html "$CPMACCFG_ETH4_IP")'">'
	echo -n ' Subnet: <input type="text" name="eth4_subnet" value="'$(html "$CPMACCFG_ETH4_SUBNET")'">'
	echo -n '</p>'
else
	SetToNull=$SetToNull'<input type="hidden" name="eth4_ip" value="">'
fi

sec_end
