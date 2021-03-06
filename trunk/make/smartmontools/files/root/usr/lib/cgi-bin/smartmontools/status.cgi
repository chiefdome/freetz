#!/bin/sh


. /usr/lib/libmodcgi.sh

DEVICES="$(cat /proc/partitions | sed -nr 's/.*[[:space:]](sd.)$/\1/p' | sort)"
COUNT=0

[ -z "$DEVICES" ] && html "$(lang de:"Keine Ger&auml;te gefunden." en:"No devices found.")"

if ! which smartctl >/dev/null 2>&1; then
	echo "<h1>$(lang de:"smartctl nicht gefunden." en:"smartctl not found.")</h1>"
	exit
fi

for DEVICE in $DEVICES; do
	let COUNT++
	[ $COUNT -gt 1 ] && echo "<hr><br>"

	DEVICE="/dev/$DEVICE"
	echo "<h1>$(lang de:"Ger&auml;t" en:"Device"): $DEVICE</h1>"

	if ! smartctl $DEVICE >/dev/null 2>&1; then
		echo "$(lang de:"S.M.A.R.T. nicht unterst&uuml;tzt" en:"S.M.A.R.T. not supported").<br><br>"
		continue
	fi

	DATAI="$(smartctl -i $DEVICE 2>/dev/null | sed  -e '1,3d')"
	NAME="$(echo "$DATAI" | sed -rn 's/Device Model: *(.*)/\1/p')"
	SIZE="$(echo "$DATAI" | sed -rn 's/User Capacity:.*\[(.*)]/\1/p')"
	DATAA="$(smartctl -A $DEVICE 2>/dev/null | sed  -e '1,3d')"
	TGC="$(echo "$DATAA" | sed -rn 's/.*Temperature_Celsius.* ([0-9]*)$/\1/p')"
	PCC="$(echo "$DATAA" | sed -rn 's/.*Power_Cycle_Count.* ([0-9]*)$/\1/p')"
	SSC="$(echo "$DATAA" | sed -rn 's/.*Start_Stop_Count.* ([0-9]*)$/\1/p')"
	POH="$(echo "$DATAA" | sed -rn 's/.*Power_On_Hours.* ([0-9]*)$/\1/p')"
	DATAH="$(smartctl -H $DEVICE 2>/dev/null | sed  -e '1,3d')"
	SMART="$(echo "$DATAH" | sed -rn 's/^SMART.*: (.*)/\1/p' | sed 's/^PASSED$/$(lang de:"GUT" en:"PASSED")/g')"

	echo "<table width=100%>"
	echo "<tr>"
	echo "<tr><td>$NAME</td><td>$SIZE</td></tr>"
	echo "<tr><td>$(lang de:"Zustand" en:"Health")</td><td>$SMART</td></tr>"
	echo "<tr><td>$(lang de:"Temperatur" en:"Termperature")</td><td>$TGC &deg;C</td></tr>"
	echo "<tr><td>$(lang de:"Laufzeit" en:"Power-on")</td><td>$(($POH/24)) $(lang de:"Tage" en:"days")</td></tr>"
	echo "<tr><td>$(lang de:"Einschalt- / Anlaufvorg&auml;nge" en:"Power cycles / spinups")</td><td>$PCC / $SSC</td></tr>"
	echo "</tr>"
	echo "</table>"

	echo -n '<pre class="log full"><FONT SIZE=-1>'
	echo -e "\n$DATAI\n\n$DATAH\n\n$DATAA\n"
	echo '</FONT></pre>'
done

