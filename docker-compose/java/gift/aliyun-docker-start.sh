#!/bin/bash
DIR=$(cd "$(dirname "$0")"; pwd)
SERVICE_NAME=$(basename $DIR)
image=$1
echo "镜像名=> $image"
docker pull $image
docker stop $SERVICE_NAME && docker rm $SERVICE_NAME 2>/dev/null
docker run -d --env-file .env --restart always --name $SERVICE_NAME $image