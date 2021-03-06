if [ "$DS_REMOVE_HELP" == "y" ]
then
	# from m*.* mod
	echo1 "removing help"
	rm -rf "${HTML_MOD_DIR}/help"
	find "${HTML_MOD_DIR}/menus" -type f |
		xargs sed -s -i -e '/var:menuHilfe/d'
	sed -i -e '/setvariable var:txtHelp/d' "${HTML_MOD_DIR}/global.inc"
	find "${HTML_MOD_DIR}/.." -name "*.html" -type f |
		xargs sed -s -i -e '/<input type="button" onclick="uiDoHelp/d'
	find "${HTML_MOD_DIR}/.." -name "*.js" -type f |
		xargs sed -s -i -e '/function uiDoHelp/,/^}/d'
	find "${HTML_MOD_DIR}/js" -name "*.js" -type f |
		xargs sed -s -i -e '/function jslPopHelp(pagename) {/,/}/d'
fi
