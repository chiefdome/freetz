[ "$FREETZ_LIB_libfreetz" == "y" ] || return 0

mkdir -p "$FILESYSTEM_MOD_DIR/usr/bin/avm/"
mv "$FILESYSTEM_MOD_DIR/usr/bin/ctlmgr" "$FILESYSTEM_MOD_DIR/usr/bin/avm/ctlmgr"

cat << 'EOF' >> "$FILESYSTEM_MOD_DIR/usr/bin/ctlmgr"
#!/bin/sh
export LD_PRELOAD=libfreetz.so
exec /usr/bin/avm/ctlmgr "$@"
EOF

chmod 755 "$FILESYSTEM_MOD_DIR/usr/bin/ctlmgr"
