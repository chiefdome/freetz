[ "$FREETZ_REMOVE_ASSISTANT" == "y" ] || return 0
# from m*.* mod
echo1 "removing assistant"

rm_files "${HTML_SPEC_MOD_DIR}/konfig" \
	 "${HTML_LANG_MOD_DIR}/html/index_assi.html" \
	 "${HTML_LANG_MOD_DIR}/html/assistent.html"

if [ "$FREETZ_REMOVE_ASSISTANT_SIP" == "y" ]; then
	# Don't delete provider.js because it's referenced by other files.
	find "${HTML_SPEC_MOD_DIR}/first" -type f -not -name "provider.js" -exec rm {} \;
else
	# Needed by "neue Rufnummer": first.frm , lib.js , *bb_backokcancel.html , first_Sip_(1|2|3)*
	rm_files \
		"${HTML_SPEC_MOD_DIR}/first/*_ISP*" \
		"${HTML_SPEC_MOD_DIR}/first/basic_first*" \
		"${HTML_SPEC_MOD_DIR}/first/first_Sip_free.*" \
		"${HTML_SPEC_MOD_DIR}/first/first_Start_Sip.*" \
		"${HTML_SPEC_MOD_DIR}/first/first_SIP_UI_*"
fi

find "${HTML_SPEC_MOD_DIR}/menus" -type f |
	xargs sed -s -i -e '/var:menuAssistent/d'

if [ -e "$HTML_SPEC_MOD_DIR/home/sitemap.html" ]; then
	if [ "$FREETZ_AVM_VERSION_05_2X_MIN" == "y" ]; then
		#lua
		linkbox_remove wizards
		#html
		linkbox_file="${HTML_SPEC_MOD_DIR}/menus/menu2.html"
		linkbox_row=$(cat $linkbox_file |nl| sed -n "s/^ *\([0-9]*\).*<a href=.javascript:jslGoTo.'konfig','home'..>.*<.a>$/\1/p")
		modsed "$((linkbox_row-13)),$((linkbox_row+19))d" $linkbox_file
	elif isFreetzType 7112 7113 7141 7150 7170 7270_V1 7570; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/${FREETZ_TYPE_LANGUAGE}/remove_assistant_${FREETZ_TYPE_PREFIX}.patch"
	elif isFreetzType 7140; then
		if isFreetzType LANG_A_CH; then
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/de/remove_assistant_7140.patch"
		else
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/de/remove_assistant.patch"
		fi
	elif [ "$FREETZ_HAS_AVM_PHONE" == "y" ]; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/de/remove_assistant.patch"
	else
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/de/remove_assistant_wop.patch"
	fi
fi
