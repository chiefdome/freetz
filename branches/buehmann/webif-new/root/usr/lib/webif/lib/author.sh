use logging
# TODO: properly implement these stubs

# check if the user is allowed to proceed (LOGIN already set)
authorized_access() {
    case $PATH_INFO in
	/test/private*) [ "$LOGIN" = admin ] ;;
	*) true ;;
    esac
    # true
}
check_authorization() {
    AUTH=false # TODO: extend to more than true/false; perhaps various "rights"?
    if authorized_access; then
	AUTH=true
	trace author "Access granted"
    else
	trace author "Access denied"
    fi
}

