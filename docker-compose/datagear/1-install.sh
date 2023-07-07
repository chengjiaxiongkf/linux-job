#!/bin/bash
mkdir -p /data/volumes/datagear
sudo curl -L https://gitee.com/datagear/datagear/releases/download/v4.6.0/datagear-4.6.0.zip -o /data/volumes/datagear/datagear-4.6.0.zip
unzip -o /data/volumes/datagear/datagear-4.6.0.zip
cp -rf docker-compose.yml Dockerfile /data/volumes/datagear/datagear-4.6.0