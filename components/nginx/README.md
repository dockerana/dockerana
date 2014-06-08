To build:

```
docker build -t schvin/nginx .
```

To run:

```
docker run -d -p 8080:80 --name dockerana-nginx --link dockerana-graphite:dockerana-graphite-link schvin/nginx
```
