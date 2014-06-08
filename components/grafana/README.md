To build:

```
docker build -t grafana .
```

To run:

```
docker run -d \
           -v /var/docker/gfdev/elastic:/var/lib/elasticsearch \
           -v /var/docker/gfdev/graphite:/opt/graphite/storage/whisper \
           -v /var/docker/gfdev/supervisor:/var/log/supervisor \
           -p 8080:80 \
           -p 8081:81 \
           -p 8125:8125/udp \
           -p 2003:2003/tcp \
           --name grafana grafana
```
