#!/bin/bash
sudo yum update sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli
sudo tee /etc/docker/daemon.json <<-'EOF'
{
     "registry-mirrors": [
         "http://hub-mirror.c.163.com",
         "https://docker.mirrors.ustc.edu.cn",
         "https://registry.docker-cn.com"
     ]
}
EOF
sudo systemctl enable docker
sudo systemctl start docker
docker version
