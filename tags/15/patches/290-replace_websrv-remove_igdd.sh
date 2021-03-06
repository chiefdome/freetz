#!/bin/bash

rm_files()
{
	for file in $1; do
		echo2 "$file"
		rm -f "$file"
	done
}

if [ "$DS_PATCH_WEBSRV" == "y" ]; then
	echo1 "removing AVM websrv"
	rm_files "$(ls -1 "${FILESYSTEM_MOD_DIR}/sbin/websrv")"
fi

if [ "$DS_PATCH_UPNP" == "y" ]; then
	echo1 "removing AVM UPnP daemon (igdd)"
	rm_files "$(ls -1 ${FILESYSTEM_MOD_DIR}/sbin/igdd)"
	rm_files "$(ls -1 ${FILESYSTEM_MOD_DIR}/lib/libavmupnp*)"
	rm_files "$(find ${FILESYSTEM_MOD_DIR}/etc -maxdepth 1 -type d -name 'default.*' | xargs -I{} find {} -name '*.xml')"
	rm_files "$(find ${FILESYSTEM_MOD_DIR}/etc -maxdepth 1 -type d -name 'default.*' | xargs -I{} find {} -name '*igd*')"
fi

if [ "$DS_PATCH_WEBSRV" == "y" ] && [ "$DS_PATCH_UPNP" == "y" ]; then
	echo1 "removing libwebsrv.so"
	rm_files "$(ls -1 ${FILESYSTEM_MOD_DIR}/lib/libwebsrv.so*)"
fi
