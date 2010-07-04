use shell

#
# Store variables as a piece of shell code. Should not be used on variable
# whose name starts with an underscore.
# Usage: store {var[=value]}+
# For example: store counter pref="green apples"
#
store() {
    local _arg _key _val
    for _arg; do
	case $_arg in
	    *=*) _key=${_arg%%=*}; _val=${_arg#$_key=} ;;
	    *) _key=$_arg; eval "_val=\$$_key" ;;
	esac
	echo "$_key=$(shell_escape "$_val")"
    done
}

# Load previously stored variables if possible; a simple 'source' would kill
# the whole script if the file has been deleted since the last [ -e $file ]
restore() {
    [ -r "$1" ] && eval "$(cat "$1" 2>/dev/null)"
}
