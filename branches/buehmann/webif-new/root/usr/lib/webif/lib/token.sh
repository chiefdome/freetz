use persistence
use random

token() {
    local token="$SESSION/.token"
    unset TOKEN

    restore "$token"

    if [ -n "$TOKEN" ]; then
	echo "$TOKEN"
	return 0
    else
	TOKEN=$(random_token) && store TOKEN > "$token" && echo "$TOKEN"
	return $?
    fi
}

# cache in environment
token_init() {
    [ -n "$TOKEN" ] || TOKEN=$(token)
}

