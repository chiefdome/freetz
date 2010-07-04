random_token() {
    local token=$(dd if=/dev/urandom bs=32 count=1 2> /dev/null | md5sum)
    [ -n "$token" ] || return 1
    echo "${token%% *}"
}
