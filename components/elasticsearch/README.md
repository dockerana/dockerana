To build:

```
docker build -t dockerana/elasticsearch .
```

To run:

```
docker run -d \
           -p 9200:9200 \
           --name dockerana-elasticsearch dockerana/elasticsearch
```
