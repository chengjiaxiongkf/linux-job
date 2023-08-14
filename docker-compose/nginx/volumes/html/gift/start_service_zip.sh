#!/bin/bash
mv ./*.zip ./backup/dist.zip_`date "+%Y%m%d%H%M%S"`
mv ./new_package/*.zip ./
unzip -o *.zip

