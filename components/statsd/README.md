To build:

```
docker build -t schvin/statsd .
```

To run:

```
docker run -d \
           -p 8126:8126 \
           -p 8125:8125/udp \
           --name dockerana-statsd --link dockerana-carbon:dockerana-carbon-link schvin/statsd
```
