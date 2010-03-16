[ "$FREETZ_PATCH_MULTIPLE_PRINTERS" == "y" ] || return 0
	echo1 "adding support for multiple printers"

	if isFreetzType 7170 && ! isFreetzType LABOR_DSL; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/275-multiple_printers_7170.patch"
	else
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/275-multiple_printers.patch"
	fi
