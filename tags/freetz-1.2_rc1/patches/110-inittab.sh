if isFreetzType 7320; then
	console="/dev/ttyS1" # 7320 uses ttyS1 as serial console
else
	console="/dev/ttyS0"
fi

cat << EOF > "${FILESYSTEM_MOD_DIR}/etc/inittab"
#
::restart:/sbin/init
::sysinit:/etc/init.d/rc.S

# Start an "askfirst" shell on the console (whatever that may be)
$console::askfirst:-/bin/sh

# Stuff to do before rebooting
::shutdown:/bin/sh -c /etc/inittab.shutdown

EOF
