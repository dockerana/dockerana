To build:

```
docker build -t schvin/graphite .
```

To run:

```
docker run -d \
           -p 8080:80 \
           -p 8125:8125/udp \
           -p 2003:2003/tcp \
           --name graphite schvin/graphite
```
