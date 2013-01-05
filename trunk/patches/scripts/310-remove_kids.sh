[ "$FREETZ_REMOVE_KIDS" == "y" ] || return 0
echo1 "removing kids files (userman/contfiltd)"
rm_files \
  ${FILESYSTEM_MOD_DIR}/bin/userman* \
  $(find ${HTML_LANG_MOD_DIR} -name 'userlist*' -o -name 'useradd*') \
  ${HTML_LANG_MOD_DIR}/internet/kids*.lua \
  ${FILESYSTEM_MOD_DIR}/sbin/contfiltd \
  ${FILESYSTEM_MOD_DIR}/etc/bpjm.data \
  ${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libuser.so

# Prevent continous reboots on 3170 with replace kernel
if [ "$FREETZ_REMOVE_DSLD" = "y" ] || ! ( isFreetzType 3170 && [ "$FREETZ_REPLACE_KERNEL" = "y" ] ); then
	rm_files $(find ${FILESYSTEM_MOD_DIR}/lib/modules -name userman)
else
	modsed "s/^modprobe kdsldmod$/modprobe kdsldmod\nmodprobe userman/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

# patcht Heimnetz > Netzwerk > Bearbeiten > Kindersicherung
modsed '/<.lua show_kisi_content() .>/d' "${HTML_LANG_MOD_DIR}/net/edit_device.lua"

# patcht Internet > Filter > Listen > Filterlisten
#lua
modsed '/^<hr>$/{N;N;N;N;N;N;N;/^<hr>\n.*385:981.*/d}' "${FILESYSTEM_MOD_DIR}/internet/trafficappl.lua"
modsed '/^<p>$/{N;N;N;N;N;/^<p>\n.*385:767.*/d}' "${FILESYSTEM_MOD_DIR}/internet/trafficappl.lua"
modsed '/^<p>$/{N;N;N;N;N;/^<p>\n.*385:122.*/d}' "${FILESYSTEM_MOD_DIR}/internet/trafficappl.lua"
modsed '/^<p>$/{N;N;N;N;N;/^<p>\n.*385:925.*/d}' "${FILESYSTEM_MOD_DIR}/internet/trafficappl.lua"
#html
modsed '/^<hr>$/{N;N;N;N;/^.*\n.*55:721.*/d}' "${FILESYSTEM_MOD_DIR}/internet/trafficappl.html"
modsed '/^<div class="ml25">$/{N;N;N;N;N;/.*\n.*55:566.*/d}' "${FILESYSTEM_MOD_DIR}/internet/trafficappl.html"
modsed '/^<div class="ml25 mb10">$/{N;N;N;N;N;/.*\n.*55:421.*/d}' "${FILESYSTEM_MOD_DIR}/internet/trafficappl.html"

# redirect on webif to prio settings
for j in home.html menu2_internet.html; do
	for i in $(find "${HTML_LANG_MOD_DIR}" -type f -name $j); do
		modsed "s/'userlist'/'trafficprio'/g" $i
	done
done

for j in userlist useradd; do
	for i in $(find "${HTML_LANG_MOD_DIR}" -type f -name '*.html' | xargs grep -l $j); do
		modsed "/$j/d" $i
	done
done

if [ -e "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init" ]; then
	modsed "s/KIDS=y/KIDS=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init"
else
	modsed "s/CONFIG_KIDS=.*$/CONFIG_KIDS=\"n\"/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
	modsed "s/CONFIG_KIDS_CONTENT=.*$/CONFIG_KIDS_CONTENT=\"n\"/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
fi
