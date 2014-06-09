To build:

```
docker build -t dockerana/graphite .
```

To run:

```
docker run -d \
           --volumes-from dockerana-carbon \
           --name dockerana-graphite dockerana/graphite
```
