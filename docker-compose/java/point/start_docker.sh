#!/bin/bash
DIR=$(cd "$(dirname "$0")"; pwd)
SERVICE_NAME=$(basename $DIR)
docker-compose down
docker rmi $SERVICE_NAME
rm -rf ./*.jar
mv ./new_jar/*.jar ./app.jar
docker-compose up --build -d
echo "重启完成"
