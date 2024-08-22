#!/bin/bash
MYSQL_USER="xxx"
MYSQL_PASSWORD="xxx"
MYSQL_DATABASE="xxx"
# 备份文件保存目录
BACKUP_DIR=" /var/lib/mysql/backup"
DATE=$(date +%Y-%m-%d)
# 定义保留天数
days_to_keep=30
mkdir -p $BACKUP_DIR/$DATE
cd $BACKUP_DIR/$DATE
mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > 1.sql

# 计算要保留的日期
date_to_keep=$(date -d "$days_to_keep days ago" +%Y-%m-%d)

# 获取目录下的所有文件夹，并按日期排序
folders=($(find "$BACKUP_DIR" -maxdepth 1 -type d -printf "%f\n" | sort))
# 循环处理文件夹
for folder in "${folders[@]}"; do
    # 检查文件夹是否是日期格式
    if [[ $folder =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        # 如果文件夹日期早于要保留的日期，就删除它
        if [[ $folder < $date_to_keep ]]; then
            rm -rf "$BACKUP_DIR/$folder"
            echo "Deleted old folder: $folder"
        fi
    fi
done