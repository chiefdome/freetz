#!/bin/sh

# initially by ramik, extended by cuma


. /mod/etc/conf/rrdstats.cfg

DATESTRING=$(date -R)
[ -n "$_cgi_width" ] && let WIDTH=_cgi_width-145 || let WIDTH=500
let HEIGHT=$WIDTH*$RRDSTATS_DIMENSIONY/$RRDSTATS_DIMENSIONX
PERIODE="24h"
RED=#EA644A
YELLOW=#ECD748
GREEN=#54EC48
BLUE=#48C4EC
RED_D=#CC3118
ORANGE_D=#CC7016
BLACK=#000000
NOCACHE="?nocache=$(date -Iseconds | sed 's/T/_/g;s/+.*$//g;s/:/-/g')"
_NICE=$(which nice)
DEFAULT_COLORS="--color SHADEA#ffffff --color SHADEB#ffffff --color BACK#ffffff --color CANVAS#eeeeee80"

generate_graph() {
	TITLE=""
	[ $# -ge 4 ] && TITLE=$4
	IMAGENAME=$3
	[ $# -ge 5 ] && IMAGENAME="$3$5"
	PERIODE=$2
	case $1 in
		cpu)
			FILE=$RRDSTATS_RRDDATA/cpu_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				[ "$RRDSTATS_CPU100PERC" = "yes" ] && CPU100PERC=" -u 100 -r "
				$_NICE rrdtool graph                         \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png             \
				--title "$TITLE"                             \
				--start now-$PERIODE                         \
				--width $WIDTH --height $HEIGHT              \
				--vertical-label "CPU usage [%]"             \
				$DEFAULT_COLORS                              \
				-l 0 $CPU100PERC $LAZY                       \
				-W "Generated on: $DATESTRING"               \
				                                             \
				DEF:user=$FILE:user:AVERAGE                  \
				DEF:nice=$FILE:nice:AVERAGE                  \
				DEF:syst=$FILE:syst:AVERAGE                  \
				DEF:wait=$FILE:wait:AVERAGE                  \
				DEF:idle=$FILE:idle:AVERAGE                  \
				CDEF:cpu=user,nice,syst,wait,+,+,+           \
				                                             \
				AREA:wait$RED:"CPU wait"                     \
				AREA:syst$GREEN:"CPU system":STACK           \
				AREA:nice$YELLOW:"CPU nice":STACK            \
				AREA:user$BLUE:"CPU user\n":STACK            \
				                                             \
				LINE1:cpu$BLACK                              \
				COMMENT:"Averaged CPU usage (min/avg/cur)\:" \
				GPRINT:cpu:MIN:"%2.1lf%% /"                  \
				GPRINT:cpu:AVERAGE:"%2.1lf%% /"              \
				GPRINT:cpu:LAST:"%2.1lf%%\n"                 > /dev/null
			fi
			;;
		mem)
			FILE=$RRDSTATS_RRDDATA/mem_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				let RAM=$(grep MemTotal /proc/meminfo | tr -s [:blank:] " " | cut -d " " -f 2)*1024
				$_NICE rrdtool graph                                            \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                                \
				--title "$TITLE"                                                \
				--start now-$PERIODE -u $RAM -r -l 0 $LAZY                      \
				--width $WIDTH --height $HEIGHT                                 \
				--vertical-label "allocation [bytes]"                           \
				$DEFAULT_COLORS                                                 \
				--base 1024 --units=si                                          \
				-W "Generated on: $DATESTRING"                                  \
				                                                                \
				DEF:used=$FILE:used:AVERAGE                                     \
				DEF:buff=$FILE:buff:AVERAGE                                     \
				DEF:cached=$FILE:cached:AVERAGE                                 \
				DEF:free=$FILE:free:AVERAGE                                     \
				                                                                \
				AREA:used$RED:"Used memory   (avg/max/cur)[bytes]\:"            \
				LINE1:used$RED_D                                                \
				GPRINT:used:AVERAGE:"%3.0lf%s /"                                \
				GPRINT:used:MAX:"%3.0lf%s /"                                    \
				GPRINT:used:LAST:"%3.0lf%s\n"                                   \
				                                                                \
				AREA:buff$BLUE:"Buffer memory (avg/max/cur)[bytes]\:":STACK     \
				GPRINT:buff:AVERAGE:"%3.0lf%s /"                                \
				GPRINT:buff:MAX:"%3.0lf%s /"                                    \
				GPRINT:buff:LAST:"%3.0lf%s\n"                                   \
				                                                                \
				AREA:cached$YELLOW:"Cache memory  (avg/max/cur)[bytes]\:":STACK \
				GPRINT:cached:AVERAGE:"%3.0lf%s /"                              \
				GPRINT:cached:MAX:"%3.0lf%s /"                                  \
				GPRINT:cached:LAST:"%3.0lf%s\n"                                 \
				                                                                \
				AREA:free$GREEN:"Free memory   (avg/max/cur)[bytes]\:":STACK    \
				GPRINT:free:AVERAGE:"%3.0lf%s /"                                \
				GPRINT:free:MAX:"%3.0lf%s /"                                    \
				GPRINT:free:LAST:"%3.0lf%s\n"                                   > /dev/null
			fi
			;;
		upt)
			FILE=$RRDSTATS_RRDDATA/upt_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                  \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                      \
				--title "$TITLE"                                      \
				--start -1-$PERIODE -l 0 -r                           \
				--width $WIDTH --height $HEIGHT $LAZY                 \
				--vertical-label "hours" -X 1                         \
				$DEFAULT_COLORS                                       \
				-W "Generated on: $DATESTRING"                        \
				                                                      \
				DEF:uptime=$FILE:uptime:MAX                           \
				                                                      \
				AREA:uptime$YELLOW:"Uptime (avg/max/cur)[hours]\:   " \
				GPRINT:uptime:AVERAGE:"%3.2lf /"                      \
				GPRINT:uptime:MAX:"%3.2lf /"                          \
				GPRINT:uptime:LAST:"%3.2lf\n"                         > /dev/null
			fi
			;;
		tt0)
			FILE=$RRDSTATS_RRDDATA/thg_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                     \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                         \
				--title "$TITLE"                                         \
				--start now-$PERIODE                                     \
				--width $WIDTH --height $HEIGHT                          \
				--vertical-label "values"                                \
				$DEFAULT_COLORS                                          \
				$LAZY                                                    \
				-W "Generated on: $DATESTRING"                           \
				                                                         \
				DEF:rx=$FILE:rx:LAST                                     \
				DEF:sn=$FILE:sn:LAST                                     \
				DEF:tx=$FILE:tx:LAST                                     \
				DEF:ip=$FILE:ip:LAST                                     \
				                                                         \
				LINE3:tx$GREEN:"Upstream    (min/avg/max/cur)[dBmV]\: "  \
				GPRINT:tx:MIN:" %5.1lf%s"                               \
				GPRINT:tx:AVERAGE:"\t%5.1lf%s"                           \
				GPRINT:tx:MAX:"\t%5.1lf%s"                               \
				GPRINT:tx:LAST:"\t%5.1lf%s\n"                            \
				                                                         \
				LINE3:sn$YELLOW:"S-N Ratio   (min/avg/max/cur)[dB]\:   " \
				GPRINT:sn:MIN:" %3.0lf%s  "                               \
				GPRINT:sn:AVERAGE:"\t%3.0lf%s  "                           \
				GPRINT:sn:MAX:"\t%3.0lf%s  "                               \
				GPRINT:sn:LAST:"\t%3.0lf%s  \n"                            \
				                                                         \
				LINE3:rx$RED:"Downstream  (min/avg/max/cur)[dBmV]\: "    \
				GPRINT:rx:MIN:" %5.1lf%s"                               \
				GPRINT:rx:AVERAGE:"\t%5.1lf%s"                           \
				GPRINT:rx:MAX:"\t%5.1lf%s"                               \
				GPRINT:rx:LAST:"\t%5.1lf%s\n"                            \
				                                                         \
				LINE3:ip$BLUE:"Computers   (min/avg/max/cur)[count]\:"   \
				GPRINT:ip:MIN:" %3.0lf%s  "                               \
				GPRINT:ip:AVERAGE:"\t%3.0lf%s  "                           \
				GPRINT:ip:MAX:"\t%3.0lf%s  "                               \
				GPRINT:ip:LAST:"\t%3.0lf%s  \n"                            > /dev/null
			fi
			;;
		tt1)
			FILE=$RRDSTATS_RRDDATA/thg_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                   \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                       \
				--title "$TITLE"                                       \
				--start now-$PERIODE                                   \
				--width $WIDTH --height $HEIGHT                        \
				--vertical-label "hours"                               \
				$DEFAULT_COLORS                                        \
				-l 0 $LAZY                                             \
				-W "Generated on: $DATESTRING"                         \
				                                                       \
				DEF:up=$FILE:up:LAST                                   \
				                                                       \
				AREA:up$YELLOW:"System Uptime (avg/max/cur)[hours]\: " \
				GPRINT:up:AVERAGE:"%3.2lf /"                           \
				GPRINT:up:MAX:"%3.2lf /"                               \
				GPRINT:up:LAST:"%3.2lf\n"                              > /dev/null
			fi
			;;
		tt2)
			FILE=$RRDSTATS_RRDDATA/thg_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                    \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                        \
				--title "$TITLE"                                        \
				--start now-$PERIODE                                    \
				--width $WIDTH --height $HEIGHT                         \
				--vertical-label "MHz"                                  \
				$DEFAULT_COLORS                                         \
				$LAZY                                                   \
				-W "Generated on: $DATESTRING"                          \
				                                                        \
				DEF:if=$FILE:if:LAST                                    \
				                                                        \
				LINE3:if$GREEN:"DS Frequency (min/avg/max/cur)[MHz]\: " \
				GPRINT:if:MIN:"%3.0lf /"                                \
				GPRINT:if:AVERAGE:"%3.0lf /"                            \
				GPRINT:if:MAX:"%3.0lf /"                                \
				GPRINT:if:LAST:"%3.0lf\n"                               > /dev/null
			fi
			;;
		tt3)
			FILE=$RRDSTATS_RRDDATA/thg_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                      \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                          \
				--title "$TITLE"                                          \
				--start now-$PERIODE                                      \
				--width $WIDTH --height $HEIGHT                           \
				--vertical-label "ID"                                     \
				$DEFAULT_COLORS                                           \
				-l 0 -u 5 $LAZY                                           \
				-W "Generated on: $DATESTRING"                            \
				                                                          \
				DEF:uc=$FILE:uc:LAST                                      \
				                                                          \
				LINE3:uc$BLUE:"Upstream Channel (min/avg/max/cur)[ID]\: " \
				GPRINT:uc:MIN:"%3.0lf   /"                                \
				GPRINT:uc:AVERAGE:"%3.0lf   /"                            \
				GPRINT:uc:MAX:"%3.0lf   /"                                \
				GPRINT:uc:LAST:"%3.0lf\n"                                 > /dev/null
			fi
			;;
		swap)
			FILE=$RRDSTATS_RRDDATA/mem_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                          \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                              \
				--title "$TITLE"                                              \
				--start -1-$PERIODE -l 0 -u 100 -r                            \
				--width $WIDTH --height $HEIGHT	$LAZY                         \
				--vertical-label "Swap usage [%]"                             \
				$DEFAULT_COLORS                                               \
				-W "Generated on: $DATESTRING"                                \
				                                                              \
				DEF:total=$FILE:swaptotal:AVERAGE                             \
				DEF:free=$FILE:swapfree:AVERAGE                               \
				CDEF:used=total,free,-                                        \
				CDEF:usedpct=100,used,total,/,*                               \
				CDEF:freepct=100,free,total,/,*                               \
				                                                              \
				AREA:usedpct#0000FF:"Used swap     (avg/max/cur)\:    "       \
				GPRINT:usedpct:AVERAGE:"%3.1lf%% /"                           \
				GPRINT:usedpct:MAX:"%3.1lf%% /"                               \
				GPRINT:usedpct:LAST:"%3.1lf%%\n"                              \
				                                                              \
				AREA:freepct#00FF00:"Free swap     (avg/max/cur)\:    ":STACK \
				GPRINT:freepct:AVERAGE:"%3.1lf%% /"                           \
				GPRINT:freepct:MAX:"%3.1lf%% /"                               \
				GPRINT:freepct:LAST:"%3.1lf%%\n"                              > /dev/null
			fi
			;;
		diskio1|diskio2|diskio3|diskio4)
			case $1 in
				diskio1)
					DISK=$RRDSTATS_DISK_DEV1
					LG=$RRDSTATS_DISK_LOGARITHM1
					MX=$RRDSTATS_MAX_DISK_GRAPH1
					;;
				diskio2)
					DISK=$RRDSTATS_DISK_DEV2
					LG=$RRDSTATS_DISK_LOGARITHM2
					MX=$RRDSTATS_MAX_DISK_GRAPH2
					;;
				diskio3)
					DISK=$RRDSTATS_DISK_DEV3
					LG=$RRDSTATS_DISK_LOGARITHM3
					MX=$RRDSTATS_MAX_DISK_GRAPH3
					;;
				diskio4)
					DISK=$RRDSTATS_DISK_DEV4
					LG=$RRDSTATS_DISK_LOGARITHM4
					MX=$RRDSTATS_MAX_DISK_GRAPH4
					;;
			esac

			if [ "$LG" = "yes" ]; then
				LOGARITHMIC=" -o "
			else
				LOGARITHMIC=" -l 0 "
			fi

			if [ -z "$MX" -o "$MX" -eq 0 ]; then
				MAXIMALBW=""
			else
				let MAXIMALBW=$MX*1000*1000
				MAXIMALBW=" -r -u $MAXIMALBW "
			fi

			FILE=$RRDSTATS_RRDDATA/$1_$RRDSTATS_INTERVAL-$DISK.rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                       \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                           \
				--title "$TITLE"                                           \
				--start -1-$PERIODE $LOGARITHMIC $LAZY $MAXIMALBW          \
				--width $WIDTH --height $HEIGHT                            \
				--vertical-label "bytes/s"                                 \
				$DEFAULT_COLORS                                            \
				--units=si                                                 \
				-W "Generated on: $DATESTRING"                             \
				                                                           \
				DEF:read=$FILE:read:AVERAGE                                \
				DEF:write=$FILE:write:AVERAGE                              \
				                                                           \
				AREA:read$GREEN:"Read        (avg/max/cur)[bytes/s]\:"     \
				GPRINT:read:AVERAGE:"%3.0lf%s /"                           \
				GPRINT:read:MAX:"%3.0lf%s /"                               \
				GPRINT:read:LAST:"%3.0lf%s\n"                              \
				                                                           \
				AREA:write#0000FF80:"Write       (avg/max/cur)[bytes/s]\:" \
				GPRINT:write:AVERAGE:"%3.0lf%s /"                          \
				GPRINT:write:MAX:"%3.0lf%s /"                              \
				GPRINT:write:LAST:"%3.0lf%s\n"                             > /dev/null
			fi
			;;
		if1|if2|if3|if4)
			case $1 in
				if1)
					IF=$RRDSTATS_INTERFACE1
					XG=$RRDSTATS_XCHG_RXTX1
					LG=$RRDSTATS_LOGARITHM1
					MX=$RRDSTATS_MAX_GRAPH1
					;;
				if2)
					IF=$RRDSTATS_INTERFACE2
					XG=$RRDSTATS_XCHG_RXTX2
					LG=$RRDSTATS_LOGARITHM2
					MX=$RRDSTATS_MAX_GRAPH2
					;;
				if3)
					IF=$RRDSTATS_INTERFACE3
					XG=$RRDSTATS_XCHG_RXTX3
					LG=$RRDSTATS_LOGARITHM3
					MX=$RRDSTATS_MAX_GRAPH3
					;;
				if4)
					IF=$RRDSTATS_INTERFACE4
					XG=$RRDSTATS_XCHG_RXTX4
					LG=$RRDSTATS_LOGARITHM4
					MX=$RRDSTATS_MAX_GRAPH4
					;;
			esac

			if [ "$XG" = "yes" ]; then
				NET_RX="out"
				NET_TX="in"
			else
				NET_RX="in"
				NET_TX="out"
			fi

			if [ "$LG" = "yes" ]; then
				LOGARITHMIC=" -o "
			else
				LOGARITHMIC=" -l 0 "
			fi

			if [ -z "$MX" -o "$MX" -eq 0 ]; then
				MAXIMALBW=""
			else
				let MAXIMALBW=$MX*1000*1000/8
				MAXIMALBW=" -r -u $MAXIMALBW "
			fi

			FILE=$RRDSTATS_RRDDATA/$1_$RRDSTATS_INTERVAL-$(echo $IF | sed 's/\:/_/g').rrd
			if [ -e $FILE ]; then
				$_NICE rrdtool graph                                     \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png                         \
				--title "$TITLE"                                         \
				--start -1-$PERIODE $LOGARITHMIC $LAZY $MAXIMALBW        \
				--width $WIDTH --height $HEIGHT                          \
				--vertical-label "bytes/s"                               \
				$DEFAULT_COLORS                                          \
				--units=si                                               \
				-W "Generated on: $DATESTRING"                           \
				                                                         \
				DEF:in=$FILE:$NET_RX:AVERAGE                             \
				DEF:out=$FILE:$NET_TX:AVERAGE                            \
				                                                         \
				AREA:in$GREEN:"Incoming    (avg/max/cur)[bytes/s]\:"     \
				GPRINT:in:AVERAGE:"%3.0lf%s /"                           \
				GPRINT:in:MAX:"%3.0lf%s /"                               \
				GPRINT:in:LAST:"%3.0lf%s\n"                              \
				                                                         \
				AREA:out#0000FF80:"Outgoing    (avg/max/cur)[bytes/s]\:" \
				GPRINT:out:AVERAGE:"%3.0lf%s /"                          \
				GPRINT:out:MAX:"%3.0lf%s /"                              \
				GPRINT:out:LAST:"%3.0lf%s"                               > /dev/null
			fi
			;;

		one)
			_SENSOR_GEN=""
			_SENSOR_CUR=0
			[ "$RRDSTATS_DIGITEMP_C" = yes ] && _SENSOR_UOM=Celsius || _SENSOR_UOM=Fahrenheit
			[ -n "$RRDSTATS_DIGITEMP_L" -o -n "$RRDSTATS_DIGITEMP_U" ] && _SENSOR_LOW="-r "
			[ -n "$RRDSTATS_DIGITEMP_L" ] && _SENSOR_LOW="$_SENSOR_LOW -l $RRDSTATS_DIGITEMP_L"
			[ -n "$RRDSTATS_DIGITEMP_U" ] && _SENSOR_LOW="$_SENSOR_LOW -u $RRDSTATS_DIGITEMP_U"

			if [ $# -ge 5 ]; then
				_SENSOR_ALI=$(grep -vE "^#|^ |^$|^//" /tmp/flash/rrdstats/digitemp.group | tr -s " " | cut -d" " -f1-2 | grep $5$ | cut -d " " -f1)
				_SENSOR_HEX=$(grep -vE "^#|^ |^$|^//" /tmp/flash/rrdstats/digitemp.alias | tr -s " " | cut -d" " -f 1,3 | grep -E "$(echo $_SENSOR_ALI | sed 's/ /\$|/g')$" | cut -d " " -f1)
			else
				_SENSOR_HEX=$(grep "^ROM " /tmp/flash/rrdstats/digitemp.conf 2>/dev/null | sed 's/^ROM .//g;s/ 0x//g')
			fi

			for _CURRENT_HEX in $_SENSOR_HEX; do
				FILE=$RRDSTATS_RRDDATA/one_${RRDSTATS_INTERVAL}-${_CURRENT_HEX}_${_SENSOR_UOM:0:1}.rrd
				if [ -e $FILE ]; then
					_ALIAS=$(grep ^$_CURRENT_HEX /tmp/flash/rrdstats/digitemp.alias | tr -s " " | cut -d " " -f3)
					[ -z "$_ALIAS" ] && _ALIAS=$_CURRENT_HEX
					_COLOR=$(grep ^$_CURRENT_HEX /tmp/flash/rrdstats/digitemp.alias | tr -s " " | cut -d " " -f2)
					[ -z "$_COLOR" ] && _COLOR="#999999"
					_SENSOR_GEN=" $_SENSOR_GEN \
					 DEF:temp$_SENSOR_CUR=$FILE:temp:AVERAGE \
					 LINE3:temp$_SENSOR_CUR$_COLOR:$_ALIAS(min/avg/max/cur)[�${_SENSOR_UOM:0:1}] \
					 GPRINT:temp$_SENSOR_CUR:MIN:\t%8.3lf \
					 GPRINT:temp$_SENSOR_CUR:AVERAGE:%8.3lf \
					 GPRINT:temp$_SENSOR_CUR:MAX:%8.3lf \
					 GPRINT:temp$_SENSOR_CUR:LAST:\t%8.3lf\n "
				fi
				let _SENSOR_CUR=_SENSOR_CUR+1
			done
			if [ -n "$_SENSOR_GEN" ]; then
				$_NICE rrdtool graph                 \
				$RRDSTATS_RRDTEMP/$IMAGENAME.png     \
				--title "$TITLE"                     \
				--start now-$PERIODE                 \
				--width $WIDTH --height $HEIGHT      \
				--vertical-label "Grad $_SENSOR_UOM" \
				$DEFAULT_COLORS                      \
				--slope-mode HRULE:0#000000          \
				$LAZY $_SENSOR_LOW                   \
				-W "Generated on: $DATESTRING"       \
				$_SENSOR_GEN                         > /dev/null
			fi
			;;
		*)
			echo "unknown graph"
			;;
	esac
	return 1
}

set_lazy() {
	LAZY=" "
	[ "$1" = "no" ] && LAZY=" -z "
}

set_period() {
	periodA=$(echo $1 | sed 's/[0-9]\+h$/hour/g;s/[0-9]\+d$/day/g;s/[0-9]\+w$/week/g;s/[0-9]\+m$/month/g;s/[0-9]\+y$/year/g')
	period0=$(echo $1 | sed 's/[a-zA-Z]//g')
	periodG=${period0}${periodA}s
	if [ $period0 -gt 1 ]; then
		periodA=" $periodA"s
	else
		period0=""
	fi
	periodnn=$period0$periodA
}

gen_main() {
	SNAME=$1
	FNAME=$2
	LAPSE=$3
	GROUP=$4
	[ $# -ge 4 ] && GROUP_URL="&group=$4"
	sec_begin "$FNAME"
	generate_graph "$SNAME" "$RRDSTATS_PERIODMAIN" "$SNAME" "" $GROUP
	echo "<center><a href=\"$SCRIPT_NAME?graph=$SNAME$GROUP_URL\" class=\"image\">"
	echo "<img src=\"/statpix/$SNAME$GROUP.png$NOCACHE\" alt=\"$FNAME stats for last $LAPSE\" border=\"0\" />"
	echo "</a></center>"
	sec_end
}

graph=$(cgi_param graph | tr -d .)
case $graph in
	cpu|mem|swap|upt|tt0|tt1|tt2|tt3|diskio1|diskio2|diskio3|diskio4|if1|if2|if3|if4|one)
		set_lazy "$RRDSTATS_NOTLAZYS"
		GROUP_PERIOD=$(cgi_param group | tr -d .)
		if [ -z "$GROUP_PERIOD" ]; then
			heading=$(echo $graph | sed "s/^upt$/Uptime/g;s/^cpu$/Processor/g;s/^mem$/Memory/g;s/^swap$/Swapspace/g;s/^tt0$/Thomson THG - basic/g;s/^tt1$/Thomson THG - System Uptime/;s/^tt2/Thomson THG - DS Frequency/;s/^tt3$/Thomson THG - Upstream Channel/;s/^diskio1$/$RRDSTATS_DISK_NAME1/g;s/^diskio2$/$RRDSTATS_DISK_NAME2/g;s/^diskio3$/$RRDSTATS_DISK_NAME3/g;s/^diskio4$/$RRDSTATS_DISK_NAME4/g;s/^if1$/$RRDSTATS_NICE_NAME1/g;s/^if2$/$RRDSTATS_NICE_NAME2/g;s/^if3$/$RRDSTATS_NICE_NAME3/g;s/^if4$/$RRDSTATS_NICE_NAME4/g;s/^one$/DigiTemp/g")
		else
			heading="$GROUP_PERIOD"
		fi
		echo "<center><font size=+1><br><b>$heading stats</b></font></center>"

		if [ $(echo "$graph" | sed 's/^tt./yes/') = yes -a "$RRDSTATS_THOMSONADV" = yes ]; then
			echo "<br><center> \
			<input type=\"button\" value=\"THG basics\" onclick=\"window.location=('$SCRIPT_NAME?graph=tt0')\" /> \
			<input type=\"button\" value=\"System Uptime\" onclick=\"window.location=('$SCRIPT_NAME?graph=tt1')\" /> \
			<input type=\"button\" value=\"DS Frequency\" onclick=\"window.location=('$SCRIPT_NAME?graph=tt2')\" /> \
			<input type=\"button\" value=\"Upstream Channel\" onclick=\"window.location=('$SCRIPT_NAME?graph=tt3')\" /> \
			</center>"
		fi

		for period in $RRDSTATS_PERIODSSUB; do
			set_period $period
			sec_begin "last $periodnn"
			generate_graph "$graph" "$periodG" "$graph-$period" "" $GROUP_PERIOD
			echo "<center><a href=\"$SCRIPT_NAME\" class=\"image\">"
			echo "<img src=\"/statpix/$graph-$period$GROUP_PERIOD.png$NOCACHE\" alt=\"$heading stats for last $periodnn\" border=\"0\" />"
			echo "</a></center>"
			sec_end
		done
		[ -n "$HTTP_REFERER" ] && backdest="history.go(-1)" || backdest="window.location.href='$SCRIPT_NAME'"
		echo "<br><center><input type=\"button\" value=\"Back\" onclick=\"javascript:$backdest\" /></center>"
		;;
	*)
		set_lazy "$RRDSTATS_NOTLAZYM"
		set_period "$RRDSTATS_PERIODMAIN"
		echo "<center><font size=+1><br><b>Stats for last $periodnn</b></font></center>"
		case $RRD_DISPLAY_TYPE in
			rrddt)
				ALL_GROUPS=$(grep -vE "^#|^$|^ " /var/tmp/flash/rrdstats/digitemp.group 2>/dev/null | tr -s " " | cut -d " " -f2 | uniq)
				[ -z "$ALL_GROUPS" ] && gen_main "one" "$curgroup" "$periodnn"
				for curgroup in $ALL_GROUPS; do
					gen_main "one" "$curgroup" "$periodnn" "$curgroup"
				done
				;;
			*)
				gen_main "cpu" "Processor" "$periodnn"
				gen_main "mem" "Memory" "$periodnn"
				[ "$(free | grep "Swap:" | awk '{print $2}')" != "0" ] && gen_main "swap" "Swapspace" "$periodnn"
				[ "$RRDSTATS_UPTIME_ENB" = yes ] && gen_main "upt" "Uptime" "$periodnn"
				[ "$RRDSTATS_THOMSONTHG" = yes ] && gen_main "tt0" "Thomson THG" "$periodnn"
				[ ! -z "$RRDSTATS_DISK_DEV1" ] && gen_main "diskio1" "$RRDSTATS_DISK_NAME1" "$periodnn"
				[ ! -z "$RRDSTATS_DISK_DEV2" ] && gen_main "diskio2" "$RRDSTATS_DISK_NAME2" "$periodnn"
				[ ! -z "$RRDSTATS_DISK_DEV3" ] && gen_main "diskio3" "$RRDSTATS_DISK_NAME3" "$periodnn"
				[ ! -z "$RRDSTATS_DISK_DEV4" ] && gen_main "diskio4" "$RRDSTATS_DISK_NAME4" "$periodnn"
				[ ! -z "$RRDSTATS_INTERFACE1" ] && gen_main "if1" "$RRDSTATS_NICE_NAME1" "$periodnn"
				[ ! -z "$RRDSTATS_INTERFACE2" ] && gen_main "if2" "$RRDSTATS_NICE_NAME2" "$periodnn"
				[ ! -z "$RRDSTATS_INTERFACE3" ] && gen_main "if3" "$RRDSTATS_NICE_NAME3" "$periodnn"
				[ ! -z "$RRDSTATS_INTERFACE4" ] && gen_main "if4" "$RRDSTATS_NICE_NAME4" "$periodnn"
				;;
		esac
		;;
esac
