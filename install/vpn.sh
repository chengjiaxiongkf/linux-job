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
sudo curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose version
mkdir -p /data/shadowsocks
cd /data/shadowsocks
yum install -y wget
wget –no-check-certificate -O shadowsocks-all.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh
chmod +x shadowsocks-all.sh
./shadowsocks-all.sh 2>&1| tee shadowsocks-all.log