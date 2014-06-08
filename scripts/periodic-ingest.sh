#!/bin/sh

IOSTAT="/tmp/iostat"
IOSTATLATEST=`ls -1t $IOSTAT* | head -3 | tail -1`

echo -n "docker.host.loadavg ";
cat /tmp/proc/loadavg

if [ -n "$IOSTATLATEST" ]; then
  sed -e 's/^/docker.host.iostat /' $IOSTATLATEST
  COUNT=`ls -1t $IOSTAT* | wc -l`
  REMOVE=`expr $COUNT - 10`
  ls -1t $IOSTAT* | tail -$REMOVE | xargs rm
#else
#  echo "no iostat yet, will have in a couple of seconds..."
fi 
iostat -y 1 1 > $IOSTAT-$$ &
