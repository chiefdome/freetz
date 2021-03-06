#!/bin/sh
#by cuma

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
. /mod/etc/conf/vnstat.cfg

URL_CGINAME=$(echo "$SCRIPT_NAME" | sed -e 's/^.*\/cgi-bin\///g' -e 's/\.cgi.*$//g')
if [ "$URL_CGINAME" != "pkgstatus" ]; then
        cgi_begin 'vnstat'
        echo '<style type="text/css">'
        echo "fieldset { margin: 0px; margin-top: 10px; margin-bottom: 10px; padding: 10px; width: $(( _cgi_width-20 ))px;}"
        echo '</style>'
        _cgi_width=$(( _cgi_width+210 ))

	cgi=$(cgi_param cgi | tr -d .)
	cgi=${cgi#vnstat/}
	URL_EXTENDED="$SCRIPT_NAME?pkg=vnstat&cgi=vnstat/$cgi"
else
    	URL_EXTENDED="$SCRIPT_NAME?"
fi

_NICE=$(which nice)
NOCACHE="?nocache=$(date -Iseconds | sed 's/T/_/g;s/+.*$//g;s/:/-/g')"
TEMPDIR=/tmp/vnstat
mkdir -p $TEMPDIR

gen_pic() {
        $_NICE vnstati -i $1 --$2 -o $TEMPDIR/$1-$2.png --config /tmp/flash/vnstat/vnstat.conf
        echo "<p><img src=\"/vnspix/$1-$2.png$NOCACHE\" alt=\"vnstat: $2 of $1\" border=\"0\"/></p>"
}

#main
sec_begin ""
echo "<center>"
netif=$(cgi_param netif)
#count ifs
ifcnt=0
for ifname in $VNSTAT_INTERFACES; do
	let ifcnt++
done
[ $ifcnt -eq 1 ] && netif=$VNSTAT_INTERFACES
#show pix
if [ -n "$netif" ]; then
	#subpages
        echo "<p><font size=+1><b>vnstat: $netif</b></font></p>"
        for period in summary hours days months top10; do
		[ $ifcnt -ne 1 ] && echo "<a href=\"$URL_EXTENDED\" class='image'>"
                gen_pic $netif $period
		[ $ifcnt -ne 1 ] && echo "</a>"
        done
        [ $ifcnt -ne 1 ] && echo "<br><input type=\"button\" value=\"Back\" onclick=\"history.go(-1)\" />"
else
	#mainpage
        echo "<p><font size=+1><b>vnstat</b></font></p>"
	[ -z "$VNSTAT_INTERFACES" ] && VNSTAT_INTERFACES=$(ls /var/lib/vnstat/ 2>/dev/null)
        for dbfile in $VNSTAT_INTERFACES; do
                echo "<a href=\"$URL_EXTENDED&netif=$dbfile\" class='image'>"
                gen_pic $dbfile summary
                echo "</a>"
        done
fi
echo "</center>"
sec_end

[ "$URL_CGINAME" != "pkgstatus" ] && cgi_end

