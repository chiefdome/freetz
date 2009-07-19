[ "$FREETZ_PATCH_VCC" == "y" ] || return 0
echo1 "applying vcc patch"
if [ -e "${HTML_LANG_MOD_DIR}/html/de" ];then 
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/de"
else
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/en"
fi
if ifFreetzType W501V W701V W901V; then
	sed -i -e "s/avme/tcom/g" "${HTML_DIR}/fon/sipoptionen.js"
else
	sed -i -e "s/avme/1und1/g" "${HTML_DIR}/fon/sipoptionen.js"
fi

