#!/bin/sh
validateUser() {
if [ "x$FORM_user" != "x" ] && [ "x$FORM_pass" != "x" ]; then
   logger freetz "ok, we got user and password"
   local entry=$(grep -n $FORM_user '/var/mod/etc/fapasswd')
   local key=$(echo "$FORM_user:$FORM_pass" | md5sum)
   for i in $key; do
      key=$i;
      break;
   done
   entry=$(echo $entry | sed 's/:/ /g')
   local n=0;
   for i in $entry; do
      if [ $n = 0 ]; then
         local uid=$i
      elif [ $n = 2 ]; then      
         local layout=$i
      elif [ $n = 3 ]; then
         local gid=$i
      elif [ $n = 4 ]; then
         local check=$i
      fi
      let "n += 1";
   done;
   export FA_THEME=$layout
   if [ "x$check" = "x$key" ]; then
      logger freetz "well, login is ok"
      local sidfile='/var/tmp/fasid'
      local chksum=$(echo "$REMOTE_ADDR:$FORM_user:$uid:$gid:$SERVER_PROTOCOL:$HTTP_USER_AGENT" | md5sum)
      for i in $chksum; do
         chksum=$i;
         break;
      done
      echo "FAABRIRA='$REMOTE_ADDR'" > $sidfile
      echo "FAABRIP='$SERVER_PROTOCOL'" >> $sidfile
      echo "FAABRIN='$uid'" >> $sidfile
      echo "FAABRIG='$gid'" >> $sidfile
      echo "FAABRIUA='$HTTP_USER_AGENT'" >> $sidfile
      echo "JAMESCOOK='$SESSIONID'" >> $sidfile
      export FA_NEXT_PAGE=$FORM_FA_USRREQ
      export FA_SID=$chksum
      export mySID=$chksum
   else 
      logger freetz "nope, login was not ok"
      export FA_NEXT_PAGE=$errorpage
   fi            
else 
   logger freetz "no user or password"
   if [ "x$errorpage" != "x" ]; then
      export FA_NEXT_PAGE=$errorpage
   else
      export FA_NEXT_PAGE='/html/login'
   fi
fi
} 
processQS() {
   local qs=$QUERY_STRING;
   local prefix='GET_'
   logger freetz "process query string [$qs]"   
   if [ "x$REQUEST_METHOD" = "xPOST" ]; then
      prefix='POST_'
      logger freetz "request method is post, read query string [$qs]"   
   fi
   export FA_QS=$qs;   
   local tmp=$(echo $qs | sed 's/&/ /g')
   for i in $tmp; do
      local k=${i%%=*}
      local t=${i##*=}
      local v=$(echo $t | sed 's/;/+/g')
      k=$prefix$(echo -e ${k//%/\\\x})
      v=$(echo -e ${v//%/\\\x})
      v=$(echo $v | sed 's/+/ /g')
      logger freetz "key [$k] has value [$v]"
      eval "export $k=\$v"
   done   
} 
validateSID() {
logger freetz "start validation of sid"
if [ "x$FA_SID" = "x" ] || [ ! -s /var/tmp/fasid ]; then
   if [ "x$errorpage" != "x" ]; then
      export FA_NEXT_PAGE=$errorpage
   else
      export FA_NEXT_PAGE='/html/login'
   fi
else
   . /var/tmp/fasid
   local entry=$(head -n $FAABRIN '/var/mod/etc/fapasswd' | tail -n 1)
   entry=$(echo $entry | sed 's/:/ /g')
   local n=0;
   for i in $entry; do
      if [ $n = 0 ]; then
         local user=$i
      elif [ $n = 1 ]; then
         local layout=$i
      elif [ $n = 2 ]; then
         local gid=$i
      elif [ $n = 3 ]; then
         local check=$i
      fi
      let "n += 1";
   done;
   export FA_THEME=$layout
   local chksum=$(echo "$FAABRIRA:$user:$FAABRIN:$gid:$FAABRIP:$FAABRIUA" | md5sum)
   for i in $chksum; do
      chksum=$i;
      break;
   done
   if [ "x$HTTP_USER_AGENT" != "x$FAABRIUA" ] ||
      [ "x$REMOTE_ADDR" != "x$FAABRIRA" ] || 
      [ "x$SERVER_PROTOCOL" != "x$FAABRIP" ] || 
      [ "x$SKOTTOWE" != "x$JAMESCOOK" ] ||
      [ "x$FA_SID" != "x$chksum" ]; then
      export FA_SID=''
      export FA_NEXT_PAGE='/html/login'
   else
      logger freetz "validation of sid passed. Login is ok"
      export mySID=$chksum
   fi
fi
}
