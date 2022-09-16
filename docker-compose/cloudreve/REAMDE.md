账号: admin@cloudreve.org
密码: JxbFPqBg

重置管理员账号密码: ./cloudreve --database-script ResetAdminPassword

官方文档:https://docs.cloudreve.org/getting-started/install#docker-compose

创建目录结构

mkdir -vp ./volumes/cloudreve/{uploads,avatar} \
&& touch ./volumes/cloudreve/conf.ini \
&& touch ./volumes/cloudreve/cloudreve.db \
&& mkdir -p ./volumes/cloudreve/aria2/config \
&& mkdir -p ./volumes/cloudreve/data/aria2 \
&& chmod -R 777 ./volumes/cloudreve/data/aria2
