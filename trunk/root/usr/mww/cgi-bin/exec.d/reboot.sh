cgi_begin '$(lang de:"Neustart" en:"Reboot")...'
echo '<p>$(lang de:"Starte neu" en:"Rebooting")...</p>'
echo '<p>$(lang de:"Nach dem Neustart <a href=\"/\" target=\"_top\">hier</a> wieder einloggen." en:"Login <a href=\"/\" target=\"_top\">here</a> after reboot.")</p>'
cgi_end
reboot
