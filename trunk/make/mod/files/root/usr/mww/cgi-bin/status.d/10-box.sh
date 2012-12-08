get_env() {
	sed -n "s/^$1	//p" /proc/sys/urlader/environment
}

[ -r /var/env.cache ] && . /var/env.cache

sec_begin "$CONFIG_PRODUKT_NAME"

cat << EOF
<table width="100%">

<tr>
<td>Firmware: $CONFIG_VERSION_MAJOR.$CONFIG_VERSION rev$(/etc/version --project 2>/dev/null) $CONFIG_LABOR_ID_NAME</td>
<td align="right">
EOF

brands_cnt=0
for i in $(ls /usr/www/); do
	case $i in
		all|cgi-bin|css|html|js|kids)
			;;
		*)
			BRANDS="$BRANDS $i"
			let brands_cnt++
			;;
	esac
done

if [ $brands_cnt -gt 1 ]; then
	echo '<form class="btn" action="/cgi-bin/exec.cgi/branding" method="post">'
	echo '$(lang de:"Branding" en:"Branding"):'
	echo '<select name="branding" size="1">'
	branding=$(get_env firmware_version)
	for i in $BRANDS; do
		echo "<option value='$i'$([ "$i" = "$branding" ] && echo ' selected')>$i</option>"
	done
	echo '</select>'
	echo '<input type="submit" value="Ok">'
	echo '</form>'
else
	branding=$(get_env firmware_version)
	BRANDS=${BRANDS# }
	echo "$(lang de:"Branding" en:"Branding"):"
	echo "$branding"
	if [ "$branding" != "$BRANDS" ]; then
		echo "($(lang de:"nicht installiert" en:"not installed"))"
	fi
fi

cat << EOF
</td>
</tr>

<tr>
<td>Freetz: $(cat /etc/.freetz-version |sed 's/freetz-//')</td>
<td align="right">Uptime: $(uptime | sed -r 's/.* up (.*), *load .*/\1/')</td>
</tr>

</table>
EOF

sec_end
