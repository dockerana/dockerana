#!/bin/bash

function dockerrun {
  echo "spinning up $1"
  docker kill load-$1
  docker rm load-$1
  docker run --name load-$1 -d $1
}

# recent top 9 featured official images on docker hub
dockerrun redis
dockerrun ubuntu:14.04
dockerrun wordpress
dockerrun mysql
dockerrun mongo
dockerrun centos:latest
dockerrun nginx
dockerrun postgres
dockerrun node
