#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

if [ -z "$PATH_INFO" ]; then
    	source extra_list.sh
	exit
fi

path_info PACKAGE ID remaining_path
if ! valid package "$PACKAGE" || ! valid id "$ID"; then
	cgi_error "Invalid path"
fi

path="$PACKAGE/$ID"
export PATH_INFO=$remaining_path
export SCRIPT_NAME="$SCRIPT_NAME/$path"

source ./extra_handler.sh
