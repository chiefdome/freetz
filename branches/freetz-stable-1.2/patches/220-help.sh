[ "$FREETZ_REMOVE_HELP" == "y" ] || return 0
# from m*.* mod
echo1 "removing help"

HELP_DIR="${HTML_LANG_MOD_DIR}/help"

if [ -e "${HELP_DIR}" ]; then
	# remove new lua help
	rm_files "${HELP_DIR}/hilfe*" "${HELP_DIR}/recht*"
	modsed 's/local g_txt/local g_txt_removed/' "${HELP_DIR}/home.html"
else
	if [ -e "${HTML_LANG_MOD_DIR}/html/de" ];then
		HTML_DIR="${HTML_LANG_MOD_DIR}/html/de"
	else
		HTML_DIR="${HTML_LANG_MOD_DIR}/html/en"
	fi
	echo1 "${HTML_DIR}"
	rm_files "${HTML_DIR}/help"
	find "${HTML_DIR}/menus" -type f |
		xargs sed -s -i -e '/var:menuHilfe/d'
	if [ -e "${HTML_DIR}/global.inc" ]; then
	    modsed '/setvariable var:txtHelp/d' "${HTML_DIR}/global.inc"
	fi
	find "${HTML_DIR}/.." -name "*.html" -type f |
		xargs sed -s -i -e '/<input type="button" onclick="uiDoHelp/d'

	# Remove functions "uiDoHelp*"
	find "${HTML_DIR}/.." -name '*.js' -type f |
		xargs -I '{}' "$TOOLS_DIR/developer/remove_js_function.sh" "{}" "uiDoHelp[[:alpha:]]*"

	# Remove functions "jslPopHelp*"
	find "${HTML_DIR}/js" -name '*.js' -type f |
		xargs -I '{}' "$TOOLS_DIR/developer/remove_js_function.sh" "{}" "jslPopHelp[[:alpha:]]*"
fi