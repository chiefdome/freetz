#! /bin/sh


. /usr/lib/libmodcgi.sh

cgi --id=firmware_update
cgi_begin '$(lang de:"Firmware-Update" en:"Firmware update")'

cat << EOF
<script type="text/javascript">
function CheckInput(form) {
	file_selector=form.elements[0];
	radio_stop=form.elements[1];
	radio_semistop=form.elements[2];
	radio_nostop=form.elements[3];
	downgrade=form.elements[4];
	delete_jffs2=form.elements[5];

	if (file_selector.value=="") {
		alert("$(lang de:"Keine Firmware-Datei angegeben!" en:"No firmware file provided!")");
		return false;
	}
	if (radio_stop.checked) {
		file_selector.name="stop_avm";
	}
	else if (radio_semistop.checked) {
		file_selector.name="semistop_avm";
	}
	else {
		file_selector.name="nostop_avm";
	}
	if (downgrade.checked) {
		file_selector.name += ":downgrade";
	}
	if (delete_jffs2.checked) {
		file_selector.name += ":delete_jffs2";
	}

	return true;
}
</script>

<h1>$(lang de:"Firmware hochladen" en:"Upload firmware")</h1>

<p>$(lang
	de:"Im ersten Schritt ist ein Firmware-Image zum Upload auszuw&auml;hlen.
Dieses Image wird auf die Box geladen und dort entpackt. Anschlie&szlig;end
wird <i>/var/install</i> aufgerufen. Falls das erfolgreich ist, kann das Update
mit einem Klick auf den Button &quot;Neustart&quot; ausgef&uuml;hrt werden. Bei
Auswahl des Men&uuml;punkts f&uuml;r Remote-Update wird die Box nach 30 Sekunden
automatisch neu gestartet."
	en:"First you are encouraged to select a firmware image for uploading. This image
will be loaded to and extracted on the box. Subsequently, <i>/var/install</i>
will be called. If successful, the update can be started by clicking the button
&quot;Reboot&quot;. If &quot;remote firmware update&quot; is selected, the box restarts
automatically after 30 seconds."
)</p>

<form action="do_firmware.cgi" method="POST" enctype="multipart/form-data" onsubmit="return CheckInput(document.forms[0]);">
	<p>
	<label for="fw_file">$(lang de:"Firmware-Image" en:"Firmware image")</label>
	<input type=file size=50 id="fw_file">
	</p>
	<p>
	<input type="radio" name="do_prepare" id="stop_avm" value="stop_avm">
	<label for="stop_avm">$(lang de:"AVM-Dienste stoppen (bei Speichermangel)" en:"Stop AVM services (less memory available)")</label><br>
	<input type="radio" name="do_prepare" id="semistop_avm" value="semistop_avm">
	<label for="semistop_avm">$(lang de:"Einen Teil der AVM-Dienste stoppen (bei Remote-Update)" en:"Stop some of the AVM services (remote firmware update)")</label><br>
	<input type="radio" name="do_prepare" id="nostop_avm" value="nostop_avm" checked>
	<label for="nostop_avm">$(lang de:"AVM-Dienste nicht stoppen (bei gen&uuml;gend Speicher bzw. Pseudo-Update ohne Reboot)" en:"Do not stop any AVM services (sufficient memory available or pseudo update without reboot)")</label>
	</p>
	<p>
	<input type="checkbox" name="downgrade" id="downgrade" value="yes">
	<label for="downgrade">$(lang de:"Downgrade auf &auml;ltere Version zulassen" en:"Allow downgrade to older version")</label>
	</p>
EOF

if $(grep -q jffs2 /proc/mtd); then
cat << EOF
	<p>
	<input id="jffs" type="checkbox" name"delete_jffs2" value="no">
	<label for="jffs">$(lang de:"JFFS2 Partition l&ouml;schen" en:"Delete JFFS2 partition")</label>
	</p>
EOF
fi

cat << EOF
	<div class="btn"><input type=submit value="$(lang de:"Firmware hochladen" en:"Upload firmware")" style="width:200px"></div>
	<div style="clear: both; text-align: right;"><a href="external.cgi">$(lang de:"external-Datei hochladen (optional)" en:"upload external file (optional)")</a></div>
</form>

EOF

cgi_end
