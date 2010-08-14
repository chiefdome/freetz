#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

path_info PACKAGE ID remaining_path
if ! valid package "$PACKAGE" || ! valid id "$ID"; then
	cgi_error "Invalid path"
	exit 1
fi

source ./status_handler.sh
