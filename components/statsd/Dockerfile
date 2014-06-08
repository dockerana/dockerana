FROM ubuntu:trusty
MAINTAINER Charlie Lewis <charliel@lab41.org>

RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN apt-get -y install python-software-properties
RUN add-apt-repository ppa:chris-lea/node.js
RUN apt-get -y update

RUN apt-get -y install git \
                       nodejs

# statsd
RUN mkdir /src && git clone https://github.com/etsy/statsd.git /src/statsd

ADD config.js /src/statsd/config.js

EXPOSE 8125/udp 8126

CMD ["/usr/bin/node", "/src/statsd/stats.js", "/src/statsd/config.js"]
