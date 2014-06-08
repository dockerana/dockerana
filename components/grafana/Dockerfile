FROM ubuntu:trusty
MAINTAINER Charlie Lewis <charliel@lab41.org>

RUN echo 'deb http://us.archive.ubuntu.com/ubuntu/ precise universe' >> /etc/apt/sources.list
RUN apt-get -y update

RUN apt-get -y install python \
                       wget

RUN mkdir /src

# grafana
RUN wget http://grafanarel.s3.amazonaws.com/grafana-1.5.3.tar.gz
RUN tar xzvf grafana-1.5.3.tar.gz && rm grafana-1.5.3.tar.gz
RUN mv grafana-1.5.3 /src/grafana

# config file
ADD config.js /src/grafana/config.js

# dashboards
ADD ./dashboards/annotations.json /src/grafana/app/dashboards/annotations.json
ADD ./dashboards/default.json /src/grafana/app/dashboards/default.json
ADD ./dashboards/graph-styles.json /src/grafana/app/dashboards/graph-styles.json
ADD ./dashboards/templated-graphs-nested.json /src/grafana/app/dashboards/templated-graphs-nested.json
ADD ./dashboards/templated-graphs.json /src/grafana/app/dashboards/templated-graphs.json
ADD ./dashboards/white-theme.json /src/grafana/app/dashboards/white-theme.json

WORKDIR /src/grafana

EXPOSE 8000

CMD ["python", "-m", "SimpleHTTPServer"]
