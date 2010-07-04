# CRLF to be used in HTTP headers
crlf=$'\r\n'

# print a header line terminated by CRLF
say() {
    echo -n "$*${crlf}"
}

# cookie management helpers
unset cookies
add_cookie() {
    cookies="${cookies}Set-Cookie: $1${crlf}"
}
say_cookies() {
    echo -n "$cookies"
}

start_response() {
    local status=$1 human
    case $status in
	200) human="OK" ;;
	301) human="Moved Permanently" ;;
	302) human="Found" ;;
	303) human="See Other" ;;
	3??) human="Unknown Redirect";;
	403) human="Forbidden" ;;
	404) human="Not Found" ;;
	4??) human="Unknown Client Error" ;;
	500) human="Internal Server Error" ;;
	5??) human="Unknown Server Error" ;;
	*) server_error 500 "Unknown status code $status" ;;
    esac
    say "Status: $status $human"
}

# Redirect the client to a different URL (e.g., after a POST request).
# Does not return.
redirect() {
    local status=$1 loc=$2
    case $status in
	3??) ;;
	*) server_error 500 "Wrong redirect status code $status" ;;
    esac
    start_response "$status"
    say_cookies
    say "Location: $loc"
    say
    exit
}

# Does not return.
server_error() {
    local status=$1 reason=$2
    case $status in
	5??) ;;
	*) server_error 500 "Wrong status code $status" ;;
    esac
    start_response "$status"
    say "Content-Type: text/plain"
    say
    echo "$reason"
    exit 1
}

# Does not return.
client_error() {
    local status=$1 reason=$2
    case $status in
	4??) ;;
	*) server_error 500 "Wrong status code $status" ;;
    esac
    start_response "$status"
    say "Content-Type: text/plain"
    say
    echo "$reason"
    exit
}
