#!/usr/bin/haserl -u 30000 -U /var/tmp -H /usr/lib/mww/do_external_handler.sh

<%
if [ -e /tmp/ex_update.done ]; then
	rm -f /tmp/ex_update.done
	exit
fi
%>

<%

. /usr/lib/libmodcgi.sh
cgi_error '$(lang de:"External-Update fehlgeschlagen." en:"external update failed.")'
%>
