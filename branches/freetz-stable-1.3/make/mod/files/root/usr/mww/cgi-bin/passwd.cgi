#!/bin/sh


. /usr/lib/libmodcgi.sh

case $REQUEST_METHOD in
	POST)   source passwd_save.sh ;;
	GET|*)  source passwd_edit.sh ;;
esac
