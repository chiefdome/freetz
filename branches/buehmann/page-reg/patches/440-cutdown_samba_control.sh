[ "$FREETZ_PACKAGE_SAMBA" == "y" ] || return 0
echo1 "remove AVM samba config"
rm_files "${FILESYSTEM_MOD_DIR}/etc/samba_config.tar"

[ "$FREETZ_HAS_USB_HOST" == "y" ] && \
sed -i -e "/killall smbd*$/d" \
	-e "s/pidof smbd/pidof/g" "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"


cat > "${FILESYSTEM_MOD_DIR}/etc/samba_control" << 'EOF'
#!/bin/sh

ICKE=$$
PIDF=/var/run/samba_control.pid

[ -r $PIDF ] || echo $$ > $PIDF
sleep 1
if [ $(ps |grep -v $ICKE|sed 's/^ \+//g'|cut -f1 -d" "|grep $(cat $PIDF)|wc -w) -eq 0 ]; then
	echo $$ > $PIDF
else
	exit
fi

. /etc/term.sh

if [ $# -ge 2 ]; then
	for SHARE in /var/media/ftp/* ; do
		rmdir $SHARE 2>/dev/null
	done
fi

/etc/init.d/rc.smbd config
if [ "$(/etc/init.d/rc.smbd status 2>/dev/null)" != "disabled" ]; then
	killall -HUP smbd
fi

rm $PIDF 2>/dev/null

EOF
