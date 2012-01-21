#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

SYSTEM_LOG="`cat /tmp/hiawatha/hiawatha.conf | grep SystemLogfile | tr -s " " | cut -d " " -f 3`"
GARBAGE_LOG="`cat /tmp/hiawatha/hiawatha.conf | grep GarbageLogfile | tr -s " " | cut -d " " -f 3`"
EXPLOIT_LOG="`cat /tmp/hiawatha/hiawatha.conf | grep ExploitLogfile | tr -s " " | cut -d " " -f 3`"
ACCESS_LOG="`cat /tmp/hiawatha/hiawatha.conf | grep AccessLogfile | tr -s " " | cut -d " " -f 3`"
ERROR_LOG="`cat /tmp/hiawatha/hiawatha.conf | grep ErrorLogfile | tr -s " " | cut -d " " -f 3`"

if [ -n "$SYSTEM_LOG" ]; then
	echo "<h1>$SYSTEM_LOG</h1>"
	echo -n '<pre class="log">'
	[ -e "$SYSTEM_LOG" ] && html < "$SYSTEM_LOG"
	echo '</pre>'
fi

if [ -n "$GARBAGE_LOG" ]; then
	echo "<h1>$GARBAGE_LOG</h1>"
	echo -n '<pre class="log">'
	[ -e "$GARBAGE_LOG" ] && html < "$GARBAGE_LOG"
	echo '</pre>'
fi

if [ -n "$EXPLOIT_LOG" ]; then
	echo "<h1>$EXPLOIT_LOG</h1>"
	echo -n '<pre class="log">'
	[ -e "$EXPLOIT_LOG" ] && html < "$EXPLOIT_LOG"
	echo '</pre>'
fi

if [ -n "$ACCESS_LOG" ]; then
	echo "<h1>$SYSTEM_LOG</h1>"
	echo -n '<pre class="log">'
	[ -e "$ACCESS_LOG" ] && html < "$ACCESS_LOG"
	echo '</pre>'
fi

if [ -n "$ERROR_LOG" ]; then
	echo "<h1>$ERROR_LOG</h1>"
	echo -n '<pre class="log">'
	[ -e "$ERROR_LOG" ] && html < "$ERROR_LOG"
	echo '</pre>'
fi
