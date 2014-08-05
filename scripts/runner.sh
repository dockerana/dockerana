#!/bin/sh

if [[ "XXX$HOSTNAME" == "XXX" ]]; then
	HOSTNAME=`hostname`
fi
export HOSTNAME

tail -F /tmp/log/syslog | /usr/local/bin/ingest.pl &
/usr/local/bin/loop.pl
