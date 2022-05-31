# 在linux中快速部署各中间件环境
前言，离职后没有公司的中间件使用，很多项目代码跑不起来了，快速集成部署一套开发环境用于项目代码使用，我是在自己电脑使用的VMware，有条件的可以使用自己的云服务器。
<br/><br/>VMware配置:<br/>cpu:8逻辑处理核<br/>内存:8G<br/>网络:NAT模式
<br/><br/> 
#### [演示图]
![image](https://raw.githubusercontent.com/chengjiaxiongkf/linux-job/master/img/all.jpg)
# 安装前置(不需要可以跳过)
sudo yum update
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# 安装docker
##### 从官网下载
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
##### 从阿里云下载
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# 安装docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 部署中间件
clone此项目,在各中间件目录下执行 "docker-compose up -d"

## Q&A:
#### 1.域名解析
vmware环境，宿主机C:\Windows\System32\drivers\etc\hosts 追加域名解析xxx.xxx.xxx.xx project.com即可指向nginx的80端口<br/>
<br/>云服务器环境,需要dnspopd之类的域名解析指向到云linux的nginx80端口，nginx需要加域名配置、证书配置、ssl配置
#### 2.nacos部署
需要先安装mysql，在同docker同network内情况，配置可以用[mysql8]容器名连接的
#### 3.xxljob部署
此xxljob是集成了nacos注册的,在执行"docker-compose up -d" 之前需要先在/docker-compose/xxljob/images 目录下执行"docker build -t 容器名 ."
<br/>作用是把jar包打包到docker本地镜像仓库（docker images）
#### 4.elk+skywalking部署
1). elasticsearch挂载的data目录要手动创建，并且给执行/写入权限 chmod 777 [目录]<br/>
2). elasticsearch部署完毕后需要进入容器初始化账号密码，初始化之后重启容器

    docker exec -it elk_elasticsearch /bin/bash #进入ES容器内部
    cd bin
    elasticsearch-setup-passwords interactive #执行 设置六个账号密码

3). logstash挂载的./volumes/logstash/conf 里面需要修改成对应elasticsearch的elastic账号的密码(我密码统一设的admin123)<br/>
4). kibana挂载的./volumes/logstash/conf 里面需要修改成对应elasticsearch的elastic账号的密码(我密码统一设的admin123)<br/>
