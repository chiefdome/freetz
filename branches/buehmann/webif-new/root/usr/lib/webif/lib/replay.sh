use persistence
use http

request_init() {
    request="$SESSION/.request"
}
save_request() {
    local request; request_init
    # FIXME: only print a selection of variables
    # export -p
    store REQUEST_METHOD REQUEST_URI > "$request"
}
replay_request() {
    local request; request_init
    # TODO: replay original request (if appropriate)
    if [ -e "$request" ]; then
	restore "$request"
	rm -f "$request"
	if [ "$REQUEST_METHOD" = GET ]; then
	    redirect 303 "$REQUEST_URI"
	fi
    fi
}
forget_request() {
    local request; request_init
    rm -f "$request"
}
