To build:

```
docker build -t dockerana/statsd .
```

To run:

```
docker run -d -P \
           --name dockerana-statsd --link dockerana-carbon:dockerana-carbon-link dockerana/statsd
```
