if  [ "$DS_PATCH_ATA" == "y" ]
then
	echo1 "applying ata patch"
	sed -i -e "s/ATA=n/ATA=y/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"
fi
