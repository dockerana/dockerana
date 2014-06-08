To build:

```
docker build -t schvin/graphite .
```

To run:

```
docker run -d \
           --volumes-from dockerana-carbon \
           --name dockerana-graphite schvin/graphite
```
