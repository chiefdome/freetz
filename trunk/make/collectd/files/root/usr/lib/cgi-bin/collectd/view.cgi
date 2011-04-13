#!/bin/sh
# cgi for viewing the collectd graphs
# Copyright 2010,  2011 Brian Jensen (Jensen.J.Brian@googlemail.com)

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

#load the configuration
. /mod/etc/conf/collectd.cfg
. /usr/share/collectd/generate_graphs

if [ -n "$COLLECTD_GRAPH_SCRIPT" ]; then
	. $COLLECTD_GRAPH_SCRIPT
fi

HOSTS_DIR=`cat /tmp/flash/collectd/collectd.conf | sed -e 's/^[ \t]*//' -n -e 's/DataDir *\"\(.*\)\"/\1/p'`
RRDTOOL=`which rrdtool`

#Error message will be printed later
if [ -d "$HOSTS_DIR" -a -n "$RRDTOOL" ]; then

	HOSTS=`ls $HOSTS_DIR`
	CGI_HOST=$(cgi_param host) 
	CGI_PLUGIN=$(cgi_param plugin)
	CGI_REFRESH=$(cgi_param refresh)
	SHOW_INTERFACE_ERRORS=$(cgi_param iferrors)

	if [ -n "$CGI_PLUGIN" ];
	then
		PERIOD=$COLLECTD_PERIODSSUB
	else
		PERIOD=$COLLECTD_PERIODMAIN
		GRAPH_MAINPAGE="yes"
	fi

	echo "<div style=\"clear: both; float: right; margin: 10px -225px 10px 20px; width: 190px;\">"
	echo "<ul class=\"menu new\">"
	if [ -z "$CGI_HOST" ]; then
		echo "<li><a class=\"active\" href=\"$SCRIPT_NAME\">Main Page</a></li>"
	else
		echo "<li><a href=\"$SCRIPT_NAME\">Main Page</a></li>"
	fi
	for HOST in $HOSTS;
	do
		if [ "$CGI_HOST" == "$HOST" -a -z "$CGI_PLUGIN" ]; then
			echo "<li class=\"open\"><a class=\"active\" href=\"$SCRIPT_NAME?host=$HOST\">$HOST</a><ul>"
		else
			echo "<li class=\"open\"><a href=\"$SCRIPT_NAME?host=$HOST\">$HOST</a><ul>"
		fi
	
		PLUGINS=`ls $HOSTS_DIR/$HOST/`
		for PLUGIN in $PLUGINS;
		do
			if [ "$CGI_HOST" == "$HOST" -a "$CGI_PLUGIN" == "$PLUGIN" ]; then
				echo "<li><a class=\"active\" href=\"$SCRIPT_NAME?host=$HOST&plugin=$PLUGIN\">$PLUGIN</a></li>"
			else
				echo "<li><a href=\"$SCRIPT_NAME?host=$HOST&plugin=$PLUGIN\">$PLUGIN</a></li>"
			fi
		done
		echo "</ul></li>"
	done
	echo "</ul></div>"

	if [ ! -e "$COLLECTD_GRAPHDIR" ]; then
		mkdir -p "$COLLECTD_GRAPHDIR"
	fi

fi

display_begin()
{
	sec_begin "$1"
}

display_graph()
{
	echo "<center>"
	if [ -n "$GRAPH_MAINPAGE" ]; then
		echo "<a href=\"$SCRIPT_NAME?host=$HOST&plugin=$PLUGIN\" class=\"image\">"
	fi
	echo "<img src=\"/graph/$HOST/$PLUGIN/$1\" alt=\"$PLUGIN stats for last $PERIOD\" border=\"0\" />"
	if [ -n "$GRAPH_MAINPAGE" ]; then
		echo "</a>"
	fi
	echo "</center>"
}

display_end()
{
	sec_end
}

process_plugin()
{
	PLUGIN_TITLE=""
	PLUGINDIR=$HOSTS_DIR/$HOST/$PLUGIN
	PLUGIN_GRAPHDIR=$COLLECTD_GRAPHDIR/$HOST/$PLUGIN
	if [ ! -e "$PLUGIN_GRAPHDIR" ]; then
		mkdir -p "$PLUGIN_GRAPHDIR"
	fi
	
	graph_plugin
	
}

process_host()
{
	if [ ! -e "$COLLECTD_GRAPHDIR/$HOST" ]; then
		mkdir -p "$COLLECTD_GRAPHDIR/$HOST"
	fi
	PLUGINS=`ls $HOSTS_DIR/$HOST/`
	
	echo "<center><h1>$HOST</h1></center>"
	
	if [ -n "$CGI_PLUGIN" -a "y" == $(echo $PLUGINS | sed  "s/.*$CGI_PLUGIN.*/y/") ];
	then
		PLUGIN="$CGI_PLUGIN"
		process_plugin
	else
		for PLUGIN in $PLUGINS;
		do
			if [ -n "$GRAPH_MAINPAGE" -a -n "$COLLECTD_MAINPAGE_PLUGINS" ]; then
				if [ "y" == $(echo "$COLLECTD_MAINPAGE_PLUGINS" | sed  "s/.*$PLUGIN.*/y/") ]; then
					process_plugin
				fi
			else
				process_plugin
			fi
		done
	fi
}

if [ -n "$CGI_HOST" -a "y" == $(echo $HOSTS | sed  "s/.*$CGI_HOST.*/y/") ];
then
	HOST=$CGI_HOST
	process_host
elif [ -n "$HOSTS" ]; then
	for HOST in $HOSTS;
	do
		if [ -n "$COLLECTD_MAINPAGE_HOSTS" ]; then
			if [ "y" == $(echo "$COLLECTD_MAINPAGE_HOSTS" | sed  "s/.*$HOST.*/y/") ]; then
				process_host
			fi
		else
			process_host
		fi
	done
else
	print_error "RRD Data directory is not valid or rrdtool was not found"
fi