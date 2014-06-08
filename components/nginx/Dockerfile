FROM ubuntu:trusty
MAINTAINER Charlie Lewis <charliel@lab41.org>

RUN apt-get -y update
RUN apt-get -y install nginx-light

ADD nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["/usr/sbin/nginx"]
