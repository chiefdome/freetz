[ "$FREETZ_PATCH_DSL_EXPERT" == "y" ] || return 0
echo1 "adding dsl expert pages"

for file in \
  ${HTML_SPEC_MOD_DIR}/internet/adsl.html \
  ${HTML_SPEC_MOD_DIR}/internet/bits.html \
  ${HTML_SPEC_MOD_DIR}/internet/atm.html \
  ${HTML_SPEC_MOD_DIR}/internet/overview.html \
  ${HTML_SPEC_MOD_DIR}/internet/feedback.html \
  ; do
	[ ! -f "$file" ] && continue
	modsed "
	s|query box:settings.expertmode.activated ?>. .1.|query box:settings/expertmode/activated ?>' '0'|
	" "$file"
	modsed "
/query box:settings.expertmode.activated ?>. .0./i \
<? if eq '<? query box:settings\/expertmode\/activated ?>' '1' \`\n\
<li><a href=\"javascript:uiDoLaborDSLPage()\">Einstellungen<\/a><\/li>\n\
\` ?>\
" "$file"
	echo2 "patching $file"
done

if isFreetzType 7270v1; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/de/dsl-expert-pages_7270_04.patch"
elif isFreetzType 7240 7270_16; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/de/dsl-expert-pages_7270_05.patch"
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/de/dsl-expert-pages_7170.patch"
fi

