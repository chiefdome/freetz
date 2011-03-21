#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$MINIDLNA_ENABLED" yes:auto "*":man
check "$MINIDLNA_INOTIFY" yes:inotify
check "$MINIDLNA_ENABLE_TIVO" yes:enable_tivo
check "$MINIDLNA_STRICT_DLNA" yes:strict_dlna

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"Konfiguration" en:"Configuration")'
local MINIDLNA_AVAILABLE_NIFS="$(ifconfig | sed -ne 's/^\([a-zA-Z.][a-zA-Z0-9]*\) .*/\1/p')"
cat << EOF

<p>
$(lang de:"Bezeichnung" en:"Description"):<br>
<input type="text" name="friendly_name" size="55" maxlength="255" value="$(html "$MINIDLNA_FRIENDLY_NAME")">
</p>

<p>
$(lang de:"Netzwerk-Interface" en:"Network interface"):&nbsp;
<input type="text" name="network_interface" size="9" maxlength="9" value="$(html "$MINIDLNA_NETWORK_INTERFACE")">
<font size=-2><br>($(lang de:"verf&uuml;gbar" en:"available"): $MINIDLNA_AVAILABLE_NIFS)</font>
</p>

<p>
$(lang de:"Port" en:"Port"):&nbsp;
<input type="text" name="port" size="5" maxlength="5" value="$(html "$MINIDLNA_PORT")">
</p>

<p>
<input type="hidden" name="enable_tivo" value="no">
<input id="c2" type="checkbox" name="enable_tivo" value="yes"$enable_tivo_chk><label for="c2">$(lang de:"aktiviere Unterst&uuml;tzung f&uuml;r TiVo mit HMO" en:"enable support for TiVo supporting HMO")</label>
</p>

<p>
<input type="hidden" name="strict_dlna" value="no">
<input id="c3" type="checkbox" name="strict_dlna" value="yes"$strict_dlna_chk><label for="c3">$(lang de:"serverseitiges Herunterrechnen von Bildern erlauben" en:"allow server-side downscaling of images")</label>
</p>

<p>
<input type="hidden" name="inotify" value="no">
<input id="c1" type="checkbox" name="inotify" value="yes"$inotify_chk><label for="c1">$(lang de:"automatisch neue Dateien erkennen" en:"automatically discover new files")</label>
</p>

<p>
$(lang de:"Benachrichtigungsintervall (Sekunden)" en:"Notify interval (seconds)"):&nbsp;
<input type="text" name="notify_interval" size="9" maxlength="9" value="$(html "$MINIDLNA_NOTIFY_INTERVAL")">
</p>

<p>
$(lang de:"Datenbankverzeichnis" en:"Database-Directory"):<br>
<input type="text" name="db_dir" size="55" maxlength="255" value="$(html "$MINIDLNA_DB_DIR")">
</p>

<p>
$(lang de:"Log-Verzeichnis" en:"Logging-Directory"):<br>
<input type="text" name="log_dir" size="55" maxlength="255" value="$(html "$MINIDLNA_LOG_DIR")">
</p>

<p>
$(lang de:"Dateinamen der Cover" en:"Album-art filenames"):<br>
<input type="text" name="album_art_names" size="55" maxlength="255" value="$(html "$MINIDLNA_ALBUM_ART_NAMES")">
</p>

<p>
$(lang de:"Medienverzeichnisse" en:"Media directories"):<br>
<textarea name="media_dir" rows="5" cols="55" maxlength="255">$(html "$MINIDLNA_MEDIA_DIR")</textarea>
</p>

EOF
sec_end
