#!/bin/sh
# Generates a Config.in of Busybox for Freetz
BBDIR="$(pwd)/$(dirname $0)"
BBVER="$(sed -n 's/$(call PKG_INIT_BIN, \(.*\))/\1/p' $BBDIR/busybox.mk)"

default_int() {
	sed -i "/^config FREETZ_BUSYBOX_$1$/{N;N;N;s/\tdefault [^\n]*/default $2/}" "$BBDIR/Config.tmp"
}

default_string() {
	sed -i "/^config FREETZ_BUSYBOX_$1$/{N;N;N;s#\tdefault [^\n]*#default \"$2\"#}" "$BBDIR/Config.tmp"
}

echo -n "unpacking ..."
rm -rf "$BBDIR/busybox-$BBVER"
tar xf "$BBDIR/../../dl/busybox-$BBVER.tar.bz2" -C "$BBDIR"

echo -n " patching ..."
cd "$BBDIR/busybox-$BBVER/"
for p in $BBDIR/patches/*.patch; do
	patch -p0 < $p >/dev/null
done

echo -n " building ..."
yes "" | make oldconfig >/dev/null

echo -n " parsing ..."
$BBDIR/../../tools/parse-config Config.in > "$BBDIR/Config.tmp" 2>/dev/null
rm -rf "$BBDIR/busybox-$BBVER"

echo -n " searching ..."
des=""
for c in $(sed -n 's/^config //p' "$BBDIR/Config.tmp"); do
	[ -n "$des" ] && des="${des};"
	des="${des}s!\([ (!]\)\($c$\)!\1FREETZ_BUSYBOX_\2!g;s!\([ (!]\)\($c[) ]\)!\1FREETZ_BUSYBOX_\2!g"
done

echo -n " replacing ..."
sed -i "$des" "$BBDIR/Config.tmp"
sed -i '/^mainmenu /d' "$BBDIR/Config.tmp"
sed -i 's!\(^#*[\t ]*default \)y\(.*\)$!\1n\2!g;' "$BBDIR/Config.tmp"

default_int "UDHCPC_SLACK_FOR_BUGGY_SERVERS" 0
default_int "UDHCP_DEBUG" 0
default_int "FEATURE_BEEP_FREQ" 0
default_int "FEATURE_BEEP_LENGTH_MS" 0
default_int "FEATURE_COPYBUF_KB" 64
default_int "FEATURE_EDITING_HISTORY" 15
default_int "FEATURE_LESS_MAXLINES" 0
default_int "FEATURE_VI_MAX_LEN" 1024
default_int "LAST_SUPPORTED_WCHAR" 0
default_int "SUBST_WCHAR" 0

default_string "BUSYBOX_EXEC_PATH" "/bin/busybox"
default_string "DHCPD_LEASES_FILE" ""
default_string "FEATURE_MIME_CHARSET" ""
default_string "IFUPDOWN_UDHCPC_CMD_OPTIONS" ""
default_string "SV_DEFAULT_SERVICE_DIR" ""
default_string "TELINIT_PATH" ""
default_string "UDHCPC_DEFAULT_SCRIPT" ""

echo -n " finalizing ..."
cat "$BBDIR/generate.tpl" "$BBDIR/Config.tmp" > "$BBDIR/Config.in"
rm -rf "$BBDIR/Config.tmp"

echo " done."
