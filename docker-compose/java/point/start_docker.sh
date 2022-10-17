#!/bin/bash
DIR=$(cd "$(dirname "$0")"; pwd)
SERVICE_NAME=$(basename $DIR)
docker-compose down
docker rmi $SERVICE_NAME
mv ./app.jar ./backup/app.jar_`date "+%Y%m%d%H%M%S"`
mv ./new_jar/*.jar ./app.jar
docker-compose up --build -d
echo "重启完成"