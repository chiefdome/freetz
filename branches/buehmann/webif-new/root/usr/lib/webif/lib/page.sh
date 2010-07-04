# tools for creating HTML5 pages
use token

# form [OPTIONS] {get|post|upload} /action "raw params"
#
# /action is relative to $WEB_ROOT or $UPLOAD_ROOT
#
# OPTIONS:
#   -t	include token (default for post and upload)
#   +t  exclude token (default for get)
form() {
    local t=2
    case $1 in
	+t) t=0; shift ;;
	-t) t=1; shift ;;
    esac
    local method=$1 action=$2 raw=$3
    echo -n "<form"
    case $method in
	get) ;;
	post|upload) echo -n " method=post" ;;
    esac
    local url
    [ -n "$action" ] && url="$WEB_ROOT$action"
    if [ "$method" = upload ]; then
	url="$UPLOAD_ROOT${action:-$PAGE$PATH_INFO}"
    fi
    if [ "$method" = upload -a $t -ne 0 ]; then
	token_init
	url="$url?_token=$TOKEN"
    fi
    # FIXME: HTML escaping?
    echo -n " action='$url'"
    if [ "$method" = upload ]; then
	echo -n " enctype=multipart/form-data"
    fi
    [ -n "$raw" ] && echo -n " $raw"
    echo -n ">"
    if [ "$method" = get -a $t -eq 1 ] ||
	[ \( "$method" = post -o "$method" = upload \) -a $t -ne 0 ]; then
	token_init
	echo -n "<input type=hidden name=_token value='$TOKEN'>"
    fi
}
end_form() {
    echo -n "</form>"
}
