echo1 "applying rc.S-dev.patch"
if [ "$DS_TYPE_LABOR_PHONE" == "y" ] || [ "$DS_TYPE_LABOR_ECO" == "y" ]; then
    modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/rc.S-dev_7170_labor_phone.patch
    else
    modpatch "$FILESYSTEM_MOD_DIR" "$PATCHES_DIR"/cond/rc.S-dev_7170_labor.patch
fi