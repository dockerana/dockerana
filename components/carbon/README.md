To build:

```
docker build -t dockerana/carbon .
```

To run:

```
docker run -d \
           -p 2003:2003 \
           -p 2004:2004 \
           -p 7002:7002 \
           -v /opt/graphite \
           --name dockerana-carbon dockerana/carbon
```
