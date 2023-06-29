#!/bin/sh
sudo curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose version
