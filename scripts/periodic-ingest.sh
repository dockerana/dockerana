#!/bin/sh

echo -n "docker.host.loadavg ";
cat /proc/loadavg

iostat | sed -e 's/^/docker.host.iostat /'
