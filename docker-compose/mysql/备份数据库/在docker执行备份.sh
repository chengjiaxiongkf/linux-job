#!/bin/bash
docker cp back-mysql.sh mysql8:/home
docker exec mysql8 sh /home/back-mysql.sh