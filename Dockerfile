FROM ubuntu:14.04
MAINTAINER George Lewis <schvin@schvin.net

RUN perl -MCPAN -e 'install Python::Seralise::Pickle'
