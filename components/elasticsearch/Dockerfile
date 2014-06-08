FROM ubuntu:trusty
MAINTAINER Charlie Lewis <charliel@lab41.org>

RUN echo 'deb http://us.archive.ubuntu.com/ubuntu/ precise universe' >> /etc/apt/sources.list
RUN apt-get -y update

RUN apt-get -y install openjdk-7-jre \
                       wget

# elasticsearch
RUN wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.deb
RUN dpkg -i elasticsearch-1.0.1.deb && rm elasticsearch-1.0.1.deb

EXPOSE 9200

CMD ["/usr/share/elasticsearch/bin/elasticsearch"]
