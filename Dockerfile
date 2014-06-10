FROM ubuntu:trusty
MAINTAINER George Lewis <schvin@schvin.net>

RUN apt-get update
RUN apt-get install -y sysstat make

RUN perl -MCPAN -e 'install Net::Statsd'

ADD scripts/ingest.pl /usr/local/bin/
ADD scripts/loop.pl /usr/local/bin/
ADD scripts/periodic-ingest.sh /usr/local/bin/
ADD scripts/runner.sh /usr/local/bin/

CMD /usr/local/bin/runner.sh
