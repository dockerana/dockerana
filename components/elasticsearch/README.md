To build:

```
docker build -t schvin/elasticsearch .
```

To run:

```
docker run -d \
           -p 9200:9200 \
           --name elasticsearch schvin/elasticsearch
```
