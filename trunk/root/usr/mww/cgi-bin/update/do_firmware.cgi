#!/usr/bin/haserl -u 20000 -U /var/tmp -H /usr/lib/mww/do_update_handler.sh

<%
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
cgi_begin '$(lang de:"Firmware-Update" en:"Firmware update")'
%>

<h1>$(lang de:"Firmware extrahieren, Update vorbereiten" en:"Extract firmware, prepare update")</h1>

<%
cat /tmp/fw_update.log
rm -f /tmp/fw_update.log
%>

<p>
<% back_button --title="$(lang de:"Zur&uuml;ck zur &Uuml;bersicht" en:"Back to main page")" mod status %>
<form action="/cgi-bin/exec.cgi/reboot" method="post"><div class="btn"><input type="submit" value="Reboot"></div></form>
</p>
<% cgi_end %>
