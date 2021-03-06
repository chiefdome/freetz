stat_begin() {
	echo '<table class="daemons">'
}

stat_button() {
	local pkg=$1 daemon=$2 cmd=$3 active=$4
	if ! $active; then disabled=" disabled"; else disabled=""; fi
	echo "<td><form class='btn' action='/cgi-bin/service.cgi/$pkg/$daemon' method='post'><input type='submit' name='cmd' value='$cmd'$disabled></form></td>"
}

stat_packagelink() {
	local url
	case $1 in
		mod) url=$(href mod conf) ;;
		*)   url=$(href cgi "$1") ;;
	esac
	echo "<a href='$url'>$2</a>"
}

stat_line() {
	local pkg=$1
	local daemon=$2
	local description=${3:-$daemon}
	local rcfile="/mod/etc/init.d/${4:-rc.$daemon}"
	local disable=${5:-false}
	local hide=${6:-false}

	$hide && return

	local start=false stop=false
	local status=$("$rcfile" status 2> /dev/null)
	case $status in
		running | 'running (inetd)')
			class=running
			stop=true
			;;
		stopped | 'stopped (inetd)')
			class=stopped
			start=true
			;;
		inetd)
			case ${inetd_status=$(inetd_status)} in
				running)
					class=running
					;;
				stopped)
					class=stopped
					;;
				none)
					class=none
					inetd_status='<i>none</i>'
					;;
				*)	class=
					;;
			esac
			status="$inetd_status ($status)"
			;;
		none)
			status='<i>none</i>'
			class=none
			start=true
			;;
		*)
			class=
			start=true; stop=true
			;;
	esac
	echo "<tr${class:+ class='$class'}>"
	echo "<td width='180'>$(stat_packagelink "$pkg" "$description")</td><td class='status' width='120'>$status</td>"

	if $disable; then
		start=false; stop=false
	fi
	stat_button "$pkg" "$daemon" start $start
	stat_button "$pkg" "$daemon" stop $stop
	stat_button "$pkg" "$daemon" restart $stop

	echo '</tr>'
}

stat_end() {
	echo '</table>'
}

unset inetd_status

inetd_status() {
	if [ -e /etc/default.inetd/inetd.cfg ]; then
		/etc/init.d/rc.inetd status 2> /dev/null
	fi
}
