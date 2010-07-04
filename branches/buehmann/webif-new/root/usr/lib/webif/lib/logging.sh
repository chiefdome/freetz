# disable trace in production code
if [ -n "$TRACE" ]; then
    export trace=
    eval 'trace() {
	local component=$1; shift
	case $component in '"$TRACE"$')
	    trace="$trace\n$*"
	    echo "$*" >&2
	    ;;
	esac
    }'
else
    trace() { true; }
fi

# warning
warn() {
    local component=$1; shift
    echo "Warning [$component]: $*" >&2
}
