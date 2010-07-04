use logging
use persistence
use random

# root directory for session state
: ${session_dir:=/tmp}

# session timeout in minutes
: ${session_timeout:=15}

# timeout for broken sessions
: ${broken_timeout:=2}

# generate session id and create state directory
new_session_dir() {
    local id
    unset SESSIONID
    # create session id & state dir: give up after a few tries
    local tries=8
    while [ $tries -gt 0 ]; do
	id=$(random_token)
	SESSION="${session_dir}/sess-${id}"
	if mkdir "$SESSION" 2> /dev/null; then
	    trace session "Created state dir $SESSION"
	    SESSIONID=$id
	    break
	elif [ ! -d "$session_dir" ]; then
	    # parent directory does not exist; give up
	    trace session "Session directory $session_dir does not exist"
	    unset SESSION SESSIONID
	    break
	fi
	unset SESSION
	let tries--
    done
    [ -n "$SESSIONID" ]
}

# remove the state directory (effectively ends the session)
del_session_dir() {
    rm -rf "$SESSION"
}

# verify session by checking additional client information
verify_session() {
    local ident="$SESSION/.ident" ident_USER_AGENT= ident_REMOTE_ADDR=
    if [ -r "$ident" ]; then
	restore "$ident"
	if [ "$REMOTE_ADDR" != "$ident_REMOTE_ADDR" ]; then
	    trace session "Remote address has changed!"
	    trace session "    old: [$ident_REMOTE_ADDR]"
	    trace session "    new: [$REMOTE_ADDR]"
	    return 1
	elif [ "$HTTP_USER_AGENT" != "$ident_USER_AGENT" ]; then
	    trace session "User agent has changed!"
	    trace session "    old: [$ident_USER_AGENT]"
	    trace session "    new: [$HTTP_USER_AGENT]"
	    return 1
	else
	    # session verified; update timestamp
	    touch -c "$ident"
	fi
    else
	# this is a new session
	store ident_REMOTE_ADDR="$REMOTE_ADDR" \
	    ident_USER_AGENT="$HTTP_USER_AGENT" > "$ident"
	trace session "User agent: [$HTTP_USER_AGENT]"
	trace session "Remote address: [$REMOTE_ADDR]"
    fi
    return 0
}

# resume previously created session if possible (returns 0 if successful)
resume_session() {
    # validate incoming session id
    case $COOKIE_session in
	*[^0-9a-f]*|"") unset SESSIONID ;;
	*) SESSIONID=$COOKIE_session ;;
    esac

    if [ -n "$SESSIONID" ]; then
	SESSION="${session_dir}/sess-${SESSIONID}"
	if [ -d "$SESSION" ]; then
	    trace session "Found state dir $SESSION"
	    if verify_session; then
		trace session "Resuming session $SESSIONID"
		return 0
	    else
		trace session "Hijacked session $SESSIONID?"
	    fi
	else
	    trace session "Stale session $SESSIONID"
	fi
    fi
    unset SESSIONID SESSION
    return 1
}

# remove expired or damaged sessions
cleanup_sessions() { ( # subshell, keep brace for syntax highlighting
    cd "${session_dir}" || return
    {
	# find old .ident files
	find . -mindepth 2 -maxdepth 2 -path "./sess-*/.ident" -type f \
	    -mmin +"$session_timeout" | while read -r ident_path; do
	    echo "$(dirname "$ident_path")"
	done
	# find old session dirs that not even have an .ident file
	find . -mindepth 1 -maxdepth 1 -name "sess-*" -type d \
	    -mmin +"$broken_timeout" | while read -r sess_path; do
	    if [ \! -e "$sess_path/.ident" ]; then
		echo "$sess_path"
	    fi
	done
    } | while read path; do
	trace session "Expiring old session ${path##*sess-}"
	rm -rf "$path"
    done
) }
