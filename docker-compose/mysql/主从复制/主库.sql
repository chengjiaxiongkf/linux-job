# 主库的my.cnf文件中设置

# 显示主库目前的binlog状态跟偏移
show master status;
 
# 创建一个复制权限的账号以及授权
CREATE USER 'replication_user'@'%' IDENTIFIED BY 'VtU8XAd28UZd4xZBYMJUtbDFdK5ssgUc';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'replication_user'@'%';
