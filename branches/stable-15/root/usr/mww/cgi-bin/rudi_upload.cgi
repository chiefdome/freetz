#!/usr/bin/haserl -u 10000 -U /var/tmp
Content-Type: text/html; charset=ISO-8859-1

<html><body>
	<pre id="cmd_output"><? if mv "$FORM_source" "$FORM_target"
		then
			echo "Datei erfolgreich nach $FORM_target hochgeladen."
			echo "Dateigr��e: $(cat ""$FORM_target"" | wc -c) Bytes"
		else
			echo
			echo "FEHLER: Entweder das Hochladen oder das Umbenennen nach"
			echo "$FORM_target war nicht m�glich."
		fi ?>
	</pre>
	<script type="text/javascript">
		window.parent.setShellOutput(document.getElementById("cmd_output").firstChild.data)
	</script>
</body></html>
