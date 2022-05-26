# 在linux中快速部署各中间件环境
前言，离职后没有公司的中间件使用，很多项目代码跑不起来了，快速集成部署一套开发环境用于项目代码使用，我是在自己电脑使用的VMware，有条件的可以使用自己的云服务器。
# 1.安装前置(不需要可以跳过)
sudo yum update
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# 2.安装docker
##### 从官网下载
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
##### 从阿里云下载
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# 3.安装docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 4.部署中间件
clone此项目到本地,在各中间件目录下执行 docker-compose up -d
