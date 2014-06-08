FROM ubuntu:14.04
MAINTAINER George Lewis <schvin@schvin.net>

RUN apt-get update

RUN perl -MCPAN -e 'install Python::Serialise::Pickle; install IO::Socket::INET'

ADD scripts/ingest.pl /usr/local/bin/
#ADD https://get.docker.io/builds/Linux/x86_64/docker-latest /usr/local/bin/docker
#RUN chmod 755 /usr/local/bin/docker

CMD /usr/bin/tail -f /tmp/log/syslog | /usr/local/bin/ingest.pl
