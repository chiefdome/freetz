#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
source /usr/lib/libmodcgi.sh

path_info PACKAGE _
if ! valid package "$PACKAGE"; then
	cgi_error "$PACKAGE: $(lang de:"Unbekanntes Paket" en:"Unknown package")"
	exit
fi

source ./conf_handler.sh
