#!/bin/bash
PARENT_DIR="$(basename "$(dirname "$(pwd)")")"
echo "当前目录的上一个目录名=> $PARENT_DIR"
DATE_TIME=$(date +'%Y%m%d%H%M%S' | tr -d ' ')
docker build -t $PARENT_DIR:$DATE_TIME .