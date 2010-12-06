[ "$FREETZ_REMOVE_MINID" == "y" ] || return 0
echo1 "removing minid files"
for files in \
	bin/minid \
	bin/minidcfg \
	bin/email.plugin \
	bin/music.plugin \
	bin/playerd_tables \
	bin/rssagg.plugin \
	bin/streamer.plugin \
	bin/telephon.plugin \
	bin/update.plugin \
	etc/minid \
	lib/libavcodec.so* \
	lib/libavformat.so* \
	lib/libavutil.so* \
	lib/libflashclient.so* \
	lib/libhttp.so* \
	lib/libmediacli.so* \
	usr/share/ctlmgr/libmini.so \
	etc/default.*/*/ringtone.wav \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

[ "$FREETZ_REMOVE_VOIPD" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libfoncclient*"
[ "$FREETZ_REMOVE_MEDIASRV" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libavmid3*.so*"
[ "$FREETZ_REMOVE_AURA_USB" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libavm_audio.so*"

# purge contents of rc.media
[ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.media" ] && echo > "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.media"

echo1 "patching rc.conf"
modsed "s/CONFIG_MINI=.*$/CONFIG_MINI=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
