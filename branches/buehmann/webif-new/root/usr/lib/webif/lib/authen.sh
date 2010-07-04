use logging
use persistence

# FIXME: configuration
: ${password_file:=$ROOT/etc/passwd}

# Check if a valid user/password pair was provided
check_credentials() {
    local user=$1 password=$2
    [ -n "$user" -a -r "$password_file" ] || return 1

    # search password database
    local _user _hash __
    while IFS=":" read -r _user _hash __; do
	if [ "$_user" = "$user" ]; then
	    local salt=${_hash#'$1$'}; salt=${salt%%\$*}
	    local hash=$(mkpasswd -m md5 "$password" "$salt")
	    if [ "$_hash" = "$hash" ]; then
		return 0
	    fi
	fi
    done < "$password_file"
    return 1
}

# login/logout
login_init() {
    login="$SESSION/.login"
}
login() {
    local user=$1 password=$2
    local login; login_init
    if check_credentials "$user" "$password"; then
	LOGIN=$user
	trace authen "Successfully authenticated as $LOGIN"
	store LOGIN > "$login"
	return 0
    else
	trace authen "Wrong username or password"
	return 1
    fi
}
restore_login() {
    local login; login_init
    unset LOGIN
    restore "$login"
    if [ -n "$LOGIN" ]; then
	trace authen "Logged in as $LOGIN"
    fi
}
logout() {
    local login; login_init
    unset LOGIN
    rm -f "$login"
}
