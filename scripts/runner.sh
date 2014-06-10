#!/bin/sh

tail -f /tmp/log/syslog | /usr/local/bin/ingest.pl &
/usr/local/bin/loop.pl
