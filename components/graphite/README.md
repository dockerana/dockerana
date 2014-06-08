To build:

```
docker build -t schvin/graphite .
```

To run:

```
docker run -d \
           -p 2003:2003 \
           -p 2004:2004 \
           -p 7002:7002 \
           -p 8125:8125/udp \
           --name dockerana-graphite schvin/graphite
```
