#!/bin/sh
cat <<EOF
<div id="content">
<div id="login">
<div class="title">
EOF
getText FA002
echo -n '</div><br/><br/><table><tr><td colspan="2">'
getText FA003
echo -n '</td></tr><tr><td>'
getText FA004
echo -n '</td><td><input type="text" name="user" size="25" maxlength="40"/></td></tr><tr><td>'
getText FA005
echo -n '</td><td><input type="password" name="pass" size="25" maxlength="50"/></td></tr><tr><td colspan="2" align="right">'
echo -n '<input onclick="javascript:dopost(); return false;" type="submit" name="submit" ' 
echo -n "value=\"$(getText OK000)\"/></td></tr>"
echo -n '</table></div></div>'
