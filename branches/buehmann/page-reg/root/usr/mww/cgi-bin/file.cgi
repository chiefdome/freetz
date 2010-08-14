#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

path_info PACKAGE ID _
if ! valid package "$PACKAGE" || ! valid id "$ID"; then
	cgi_error "Invalid path"
	exit 2
fi

source ./file_handler.sh
