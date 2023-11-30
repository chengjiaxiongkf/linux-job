# 开启主从复制
CHANGE MASTER TO 
 MASTER_HOST='111.230.64.242', 
 MASTER_USER='replication_user', 
 MASTER_PASSWORD='VtU8XAd28UZd4xZBYMJUtbDFdK5ssgUc', 
 MASTER_LOG_FILE='binlog.000004', 
 MASTER_LOG_POS=2549651;
 
#停止
stop slave

#启动
start slave

# 显示同步状态(Slave_IO_Running跟Slave_SQL_Running为Yes即可)
show slave status;