#!/bin/bash
mkdir -vp ./volumes/cloudreve/{uploads,avatar} \
&& touch ./volumes/cloudreve/cloudreve.db \
&& mkdir -p ./volumes/cloudreve/aria2/config \
&& mkdir -p ./volumes/cloudreve/data/aria2 \
&& chmod -R 777 ./volumes/cloudreve/data/aria2
docker-compose up -d 