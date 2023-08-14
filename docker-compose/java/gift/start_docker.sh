#!/bin/bash
DIR=$(cd "$(dirname "$0")"; pwd)
SERVICE_NAME=$(basename $DIR)
file="./target/app.jar"
docker-compose down && docker rmi $SERVICE_NAME 2>/dev/null
if [ -f "$file" ]; then
  mv ./target/*.jar ./backup/app.jar_`date "+%Y%m%d%H%M%S"`
  echo "备份上一次jar包"
fi
mv ./new_jar/*.jar ./target/app.jar
docker-compose up --build -d
echo "重启完成"
