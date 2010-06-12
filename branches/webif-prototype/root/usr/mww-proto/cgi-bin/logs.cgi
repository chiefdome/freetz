#!/bin/sh
echo '<div id="content">'
echo '<div id="logs"><pre>'
#tail -n 100 '/var/log/messages.1'
logread
echo '</pre></div>'
echo '<div id="control">'
echo '<input type="button" name="download" value="Download"/><input type="button" name="refresh" value="Refresh" onclick="javascript:select('/cgi-bin/logs');"/>'
echo '</div></div>'
