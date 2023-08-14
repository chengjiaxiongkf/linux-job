#!/bin/bash
mv ./*.tar.gz ./backup/dist.tar.gz_`date "+%Y%m%d%H%M%S"`
mv ./new_package/*.tar.gz ./
tar -zxvf *.tar.gz
