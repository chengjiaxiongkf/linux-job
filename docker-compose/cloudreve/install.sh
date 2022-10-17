#!/bin/bash
mkdir -vp /data/volumes/cloudreve/{uploads,avatar} \
&& touch /data/volumes/cloudreve/cloudreve.db \
&& mkdir -p /data/volumes/cloudreve/aria2/config \
&& mkdir -p /data/volumes/cloudreve/data/aria2 \
&& chmod -R 777 /data/volumes/cloudreve/data/aria2
docker-compose up -d 