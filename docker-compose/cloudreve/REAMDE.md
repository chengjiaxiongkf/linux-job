账号: admin@cloudreve.org
密码: JxbFPqBg

重置管理员账号密码: ./cloudreve --database-script ResetAdminPassword

官方文档:https://docs.cloudreve.org/getting-started/install#docker-compose

创建目录结构

mkdir -vp /data/volumes/cloudreve/{uploads,avatar} \
&& touch /data/volumes/cloudreve/conf.ini \
&& touch /data/volumes/cloudreve/cloudreve.db \
&& mkdir -p /data/volumes/cloudreve/aria2/config \
&& mkdir -p /data/volumes/cloudreve/data/aria2 \
&& chmod -R 777 /data/volumes/cloudreve/data/aria2
