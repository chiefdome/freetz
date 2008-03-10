DTMFBOX_VERSION="v0.4.0 (3)"
www_script="http://fritz.v3v.de/dtmfbox/dtmfbox-0.4.0_1-dl/rc.dtmfbox"
FREETZ="1"
package=dtmfbox

MAX_ACCOUNTS=10             # max. number of accounts: 10
MAX_DTMFS=50                # max. number of dtmf-commands: 50
SAVE_PREVIEW=0              # preview of debug.cfg, boot.cfg?

# mod specific settings
if [ "$FREETZ" = "0" ];
then
  HTTPD="/var/dtmfbox/busybox-tools httpd"
  NC="/var/dtmfbox/busybox-tools nc"
  DU="/var/dtmfbox/busybox-tools du"
else
  HTTPD="httpd"
  NC="nc"
  DU="du"
fi
