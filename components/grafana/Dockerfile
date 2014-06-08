FROM ubuntu:14.04
MAINTAINER Charlie Lewis <charliel@lab41.org>

RUN echo 'deb http://us.archive.ubuntu.com/ubuntu/ precise universe' >> /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN apt-get -y install python-software-properties
RUN add-apt-repository ppa:chris-lea/node.js
RUN apt-get -y update

RUN apt-get -y install curl \
                       git \
                       gunicorn \
                       nginx-light \
                       nodejs \
                       openjdk-7-jre \
                       python-django-tagging \
                       python-simplejson \
                       python-memcache \
                       python-ldap \
                       python-cairo \
                       python-django \
                       python-twisted \
                       python-pysqlite2 \
                       python-support \
                       python-pip \
                       supervisor \
                       wget

# elasticsearch
WORKDIR /root
RUN wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.deb
RUN dpkg -i elasticsearch-1.0.1.deb && rm elasticsearch-1.0.1.deb

# statsd
RUN mkdir /src && git clone https://github.com/etsy/statsd.git /src/statsd

# graphite
WORKDIR /usr/local/src
RUN git clone https://github.com/graphite-project/graphite-web.git
RUN git clone https://github.com/graphite-project/carbon.git
RUN git clone https://github.com/graphite-project/whisper.git
RUN cd whisper && git checkout master && python setup.py install
RUN cd carbon && git checkout 0.9.x && python setup.py install
RUN cd graphite-web && git checkout 0.9.x && python check-dependencies.py; python setup.py install

# add graphite config
ADD ./graphite/initial_data.json /opt/graphite/webapp/graphite/initial_data.json
ADD ./graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
ADD ./graphite/carbon.conf /opt/graphite/conf/carbon.conf
ADD ./graphite/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
ADD ./graphite/storage-aggregation.conf /opt/graphite/conf/storage-aggregation.conf

RUN mkdir -p /opt/graphite/storage/whisper
RUN touch /opt/graphite/storage/graphite.db /opt/graphite/storage/index
RUN chown -R www-data /opt/graphite/storage
RUN chmod 0775 /opt/graphite/storage /opt/graphite/storage/whisper
RUN chmod 0664 /opt/graphite/storage/graphite.db
RUN cd /opt/graphite/webapp/graphite && python manage.py syncdb --noinput

# grafana
WORKDIR /tmp
RUN wget http://grafanarel.s3.amazonaws.com/grafana-1.5.3.tar.gz
RUN tar xzvf grafana-1.5.3.tar.gz && rm grafana-1.5.3.tar.gz
RUN mv /tmp/grafana-1.5.3 /src/grafana

# fake data generator
ADD ./fake-data-gen /src/fake-data-gen
WORKDIR /src/fake-data-gen
RUN npm install

# config files
ADD ./statsd/config.js /src/statsd/config.js
ADD ./grafana/config.js /src/grafana/config.js
ADD ./elasticsearch/run /usr/local/bin/run_elasticsearch
ADD ./nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/var/lib/elasticsearch"]
VOLUME ["/opt/graphite/storage/whisper"]
VOLUME ["/var/lib/log/supervisor"]

# graphite/grafana/carbon[3]/statsd[2]
EXPOSE 80 81 2003 2004 7002 8125/udp 8126 

CMD ["/usr/bin/supervisord"]
