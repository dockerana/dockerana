To build:

```
docker build -t schvin/statsd .
```

To run:

```
docker run -d -P \
           --name dockerana-statsd --link dockerana-carbon:dockerana-carbon-link schvin/statsd
```
