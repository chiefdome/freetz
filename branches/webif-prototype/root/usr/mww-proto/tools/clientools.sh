source ../tools/logging.sh

FA_PASSWD_FILE=/var/mod/etc/fapasswd
FA_SID_FILE=/var/tmp/fasid
FA_LOGIN_PAGE=/html/login

# Prints $1 such that it may safely be read by the shell
shell_escape() {
   echo "'${1//'/'\\''}'"
} 

# Returns the MD5 hash of $1 + LF
md5_hash() {
   local md5=$(echo "$1" | md5sum)
   echo "${md5%% *}"
}

validateUser() {
if [ -n "$FORM_user" -a -n "$FORM_pass" ]; then
   log_info "ok, we got user and password"
   local key=$(echo "$FORM_user:$FORM_pass" | md5sum)
   key=${key%% *}
   local entry=$(grep -n $FORM_user "$FA_PASSWD_FILE")
   local IFS=":"
   set -- $entry
   local uid=$1 layout=$3 gid=$4 check=$5
   export FA_THEME=$layout
   if [ "$check" = "$key" ]; then
      log_info "well, login is ok"
      local chksum=$(md5_hash "$REMOTE_ADDR:$FORM_user:$uid:$gid:$HTTP_USER_AGENT")
      export FA_NEXT_PAGE=$FORM_usrreq
      export FA_SID=$chksum
      export FA_TOKEN=$SESSIONID
      export sec_level=$gid
      cat > "$FA_SID_FILE" << EOF
FA_REMOTE_ADDR=$(shell_escape "$REMOTE_ADDR")
FA_UID=$(shell_escape "$uid")
FA_GID=$(shell_escape "$gid")
FA_USER_AGENT=$(shell_escape "$HTTP_USER_AGENT")
FA_TOKEN=$(shell_escape "$FA_TOKEN")
EOF
   else 
      log_info "nope, login was not ok"
      log_info "check is  [$check]"   
      log_info "should be [$key]"
      export FA_NEXT_PAGE=$FORM_errorpage
      rm -f "$FA_SID_FILE"
   fi            
else 
   log_info "no user or password"
   export FA_NEXT_PAGE=${FORM_errorpage:-$FA_LOGIN_PAGE}
fi
}

validateSID() {
log_info "start validation of sid"
if [ -z "$FORM_sid" -o ! -s "$FA_SID_FILE" ]; then
   log_info "my sid is empty or session vars invalid"
   export FA_NEXT_PAGE=${FORM_errorpage:-$FA_LOGIN_PAGE}
else
   log_info "ok, we have a sid and session vars ..."
   . "$FA_SID_FILE"
   local entry=$(head -n $FA_UID "$FA_PASSWD_FILE" | tail -n 1)
   local IFS=":"
   set -- $entry
   local user=$1 layout=$2 gid=$3 check=$4
   export FA_THEME=$layout
   local chksum=$(md5_hash "$FA_REMOTE_ADDR:$user:$FA_UID:$gid:$FA_USER_AGENT")
   local valid=true reason=
   if [ "$HTTP_USER_AGENT" != "$FA_USER_AGENT" ]; then
       valid=false
       reason="user agent changed: [$FA_USER_AGENT] -> [$HTTP_USER_AGENT]"
   elif [ "$REMOTE_ADDR" != "$FA_REMOTE_ADDR" ]; then
       valid=false
       reason="remote address changed: [$FA_REMOTE_ADDR] -> [$REMOTE_ADDR]"
   elif [ "$FORM_token" != "$FA_TOKEN" ]; then
       valid=false
       reason="wrong token: expected [$FA_TOKEN], received [$FORM_token]"
   elif [ "$FORM_sid" != "$chksum" ]; then
       valid=false
       reason="wrong session id: expected [$chksum], received [$FORM_sid]"
   fi
   if ! $valid; then
      log_info "session check failed! $reason"
      export FA_SID=''
      export FA_NEXT_PAGE=$FA_LOGIN_PAGE
      rm -f "$FA_SID_FILE"
   else
      log_info "validation of sid passed. Login is ok"
      export sec_level=$gid
      export FA_SID=$chksum
      export FA_TOKEN=$SESSIONID
      export FA_NEXT_PAGE=$FORM_page
      # Rewrite sidfile with new token
      cat > "$FA_SID_FILE" << EOF
FA_REMOTE_ADDR=$(shell_escape "$REMOTE_ADDR")
FA_UID=$(shell_escape "$FA_UID")
FA_GID=$(shell_escape "$gid")
FA_USER_AGENT=$(shell_escape "$HTTP_USER_AGENT")
FA_TOKEN=$(shell_escape "$FA_TOKEN")
EOF
   fi
fi
}
