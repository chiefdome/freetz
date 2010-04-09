#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

sec_begin '$(lang de:"Fortune Einstellungen" en:"Fortune settings")'

cat << EOF
<h2>$(lang de:"Verzeichnis mit fortune-Dateien" en:"Directory with fortune-files"):</h2>
<p><input type="text" name="dir" size="50" maxlength="254" value="$(html "$FORTUNE_DIR")"></p>
</p>
<p style="font-size:10px;">$(lang de:"Im fortune-Verzeichnis sollten sich einige fortune-Dateien befinden, aus denen fortune Aphorismen, Gl�ckskekse und Zitate ausw�hlen kann. Fortune-Dateien findet man zum Beispiel im Repository von FreeBSD, <a href="http://www.freebsd.org/cgi/cvsweb.cgi/src/games/fortune/datfiles/">also hier</a>." en:"There should be some fortune-files in the fortune-directory for fortune to use. Such fortune-files may for example be found in the FreeBSD repository, <a href="http://www.freebsd.org/cgi/cvsweb.cgi/src/games/fortune/datfiles/">here</a>.")</p>
EOF

sec_end
