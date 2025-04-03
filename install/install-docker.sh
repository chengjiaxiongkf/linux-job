#!/bin/bash
# 如果yum下载报错，设置镜像源
# curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
sudo yum update && sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli
sudo tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
        "https://docker.211678.top/",
        "https://docker.1panel.live/",
        "https://hub.rat.dev/",
        "https://docker.m.daocloud.io/",
        "https://do.nark.eu.org/",
        "https://dockerpull.com/",
        "https://dockerproxy.cn/",
        "https://docker.awsl9527.cn/"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    }
}
EOF
sudo systemctl enable docker
sudo systemctl start docker
docker version
