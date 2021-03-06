#!/bin/bash

FN_IMAGE="dl/*-7553.image"
FN_ZIP="dl/*-7553.zip"

FILES1="
./usr/lib/mediasrv/ConnectionManager.xml
./usr/lib/mediasrv/MediaServerDevDesc-template.xml
./usr/lib/mediasrv/mediapath
./usr/lib/mediasrv/MediaServerDevDesc.xml
./usr/lib/mediasrv/ContentDirectory.xml
./sbin/stop_mediasrv
./sbin/mediasrv
./sbin/start_mediasrv
"
FILES2="
./etc/default.Fritz_Box_7170_26/avm/ConnectionManager.xml
./etc/default.Fritz_Box_7170_26/avm/MediaServerDevDesc-template.xml
./etc/default.Fritz_Box_7170_26/avm/mediapath
./etc/default.Fritz_Box_7170_26/avm/MediaServerDevDesc.xml
./etc/default.Fritz_Box_7170_26/avm/ContentDirectory.xml
./etc/default.Fritz_Box_7170_26/1und1/ConnectionManager.xml
./etc/default.Fritz_Box_7170_26/1und1/MediaServerDevDesc-template.xml
./etc/default.Fritz_Box_7170_26/1und1/mediapath
./etc/default.Fritz_Box_7170_26/1und1/MediaServerDevDesc.xml
./etc/default.Fritz_Box_7170_26/1und1/ContentDirectory.xml
./etc/default.Fritz_Box_7170_26/freenet/ConnectionManager.xml
./etc/default.Fritz_Box_7170_26/freenet/MediaServerDevDesc-template.xml
./etc/default.Fritz_Box_7170_26/freenet/mediapath
./etc/default.Fritz_Box_7170_26/freenet/MediaServerDevDesc.xml
./etc/default.Fritz_Box_7170_26/freenet/ContentDirectory.xml
"

if [ "$DS_PATCH_MEDIASRV" == "y" ]; then

	TMPDIR="$FILESYSTEM_MOD_DIR/../../mediasrv"

	if [ ! -d $TMPDIR ] ; then
		if [ ! -f $FN_IMAGE ] ; then
			if [ ! -f $FN_ZIP ] ; then
				echo1 "media server patch: neither firmware image nor zip file found"
				exit 1
			fi
			echo1 "media server patch: extracting USB Labor firmware from zip file"
			unzip $FN_ZIP '*.image' -d dl
			if [ ! -f $FN_IMAGE ] ; then
				echo1 "media server patch: could not unpack zip file"
				exit 1
			fi
		fi
		echo1 "media server patch: extracting USB Labor firmware"
		./fwmod -d $TMPDIR -u $FN_IMAGE > /dev/null
	fi

	echo1 "media server patch: copying files"
	for F in $FILES1 ; do
		mkdir -p $FILESYSTEM_MOD_DIR/`dirname $F`
		cp -a $TMPDIR/original/filesystem/$F $FILESYSTEM_MOD_DIR/$F
	done
	for F in $FILES2 ; do
		TARGETDIR=`ls -d $FILESYSTEM_MOD_DIR/etc/default.Fritz_Box*/avm`
		cp -a $TMPDIR/original/filesystem/$F $TARGETDIR/`basename $F`
	done

	echo1 "patching MEDIASRV in rc.init"
	sed -i -e "s/MEDIASRV=n/MEDIASRV=y/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init"

	echo1 "patching isMedia in rc.S"
	sed -i -e "s/isMediaSrv 0/isMediaSrv 1/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.S"
fi
