FROM ubuntu:14.04
MAINTAINER George Lewis <schvin@schvin.net

RUN apt-get update

RUN perl -MCPAN -e 'install Python::Serialise::Pickle; install IO::Socket::INET'

ADD scripts/ingest.pl /usr/local/bin/
