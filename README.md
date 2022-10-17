# 在linux中快速部署各中间件环境
前言，离职后没有公司的中间件使用，很多项目代码跑不起来了，快速集成部署一套开发环境用于项目代码使用，我是在自己电脑使用的VMware，有条件的可以使用自己的云服务器。
<br/><br/>VMware配置:<br/>cpu:8逻辑处理核<br/>内存:8G<br/>网络:NAT模式
<br/><br/> 

#### [演示图]
![image](https://raw.githubusercontent.com/chengjiaxiongkf/linux-job/master/img/all.jpg)
# 安装前置(不需要可以跳过)
sudo yum update
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
##### 从官网下载(网络超时的话重试几遍或者换下载地址)
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
##### 从阿里云下载(网络超时的话重试几遍或者换下载地址)
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# 安装docker
sudo yum install docker
# 开机启动docker
sudo systemctl enable docker
# 启动docker
sudo systemctl start docker
# 验证docker
docker version
# 安装docker-compose(网络超时的话重试几遍)
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# 目录授权
sudo chmod +x /usr/local/bin/docker-compose
# 验证docker-compose
docker-compose version

# 安装git
yum -y install git

# 部署软件
clone此项目,在各中间件目录下执行 "docker-compose up -d"

# 软件目录

docker-compose：

​		cloudreve(开源项目，私有云盘)

​		elk+skywalking(ELK+skywalking日志系统)

​		frp(内网穿透)

​		git(代码管理工具)

​		grafana(开源数据可视化web)

​		java(docker容器部署java)

​		mysql(关系型ACID数据库，含5.7、8.0两版本)

​		nacos(alibaba cloud nacos注册中心)

​		nginx(nginx网关)

​		redis(缓存中间件)

​		rocketmq(apche顶级开源消息队列）

​		xxljob(定时任务调度平台，支持java，python，shell等多种方式定时执行)

job:

​		fineBI(商业级报表系统，2个账号并发内免费)

​		java(jar包部署java应用)

​		maven(包管理工具)

​		squid(网络代理)

## Q&A:
#### 设置linux时区
timedatectl list-timezones  #列出所有时区
timedatectl set-timezone Asia/Shanghai #修改为XX时区
#### docker镜像源
echo '{
     "registry-mirrors": [
         "http://hub-mirror.c.163.com",
         "https://docker.mirrors.ustc.edu.cn",
         "https://registry.docker-cn.com"
     ]
}' > /etc/docker/daemon.json
#### 域名解析
vmware环境，宿主机C:\Windows\System32\drivers\etc\hosts 追加域名解析xxx.xxx.xxx.xx project.com即可指向nginx的80端口<br/>
<br/>云服务器环境,需要dnspod之类的域名解析指向到云linux的nginx80端口，nginx需要加域名配置、证书配置、ssl配置

#### mysql部署
<需要先 docker network create vlan-mysql （目的是为了跟其他容器映射，使其直接使用容器名内网访问, 不需要的可以删除相关配置）>

#### nacos部署
<需要先安装mysql><需要先 docker network create vlan-nacos（目的是为了跟其他容器映射，使其直接使用容器名内网访问, 不需要的可以删除相关配置）>

#### xxljob部署
此xxljob是集成了nacos注册的,在执行"docker-compose up -d" 之前需要先在/docker-compose/xxljob/images 目录下执行"docker build -t 容器名 ."
<br/>作用是把jar包打包到docker本地镜像仓库（docker images）

#### elk+skywalking部署
1). elasticsearch挂载的data目录要手动创建，并且给执行/写入权限 chmod a+rwx [目录]<br/>
2). elasticsearch部署完毕后需要进入容器初始化账号密码，初始化之后重启容器

    docker exec -it elk_elasticsearch /bin/bash #进入ES容器内部
    cd bin
    elasticsearch-setup-passwords interactive #执行 设置六个账号密码

3). logstash挂载的./volumes/logstash/conf 里面的两个文件中的user/password需要修改成对应elasticsearch的elastic账号的密码(es密码默认设的admin123)<br/>
4). kibana挂载的./volumes/logstash/conf 里面需要修改成对应elasticsearch的elastic账号的密码(es密码默认设的admin123)<br/>

#### grafana部署
<需要先对volumn文件夹授权所有人读写权限 chmod a+rwx ./volumes/*>

#### 有空再写...
