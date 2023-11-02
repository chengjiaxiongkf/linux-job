#!/bin/bash
DIR=$(cd "$(dirname "$0")"; pwd)
SERVICE_NAME=$(basename $DIR)
echo "当前目录名=> $SERVICE_NAME"
image=$1
echo "镜像名=> $image"
docker pull $image 2>/dev/null
echo "下载镜像完成"
docker stop $SERVICE_NAME && docker rm $SERVICE_NAME 2>/dev/null
echo "停止删除老容器"
docker run -d -p 8081:8081 -v /data/devops/java/mes/file:/java/file  --env-file .env --restart always --name $SERVICE_NAME $image
echo "启动成功"