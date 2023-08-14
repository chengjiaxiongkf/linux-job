#!/bin/bash
echo "下载htpasswd>>> yum -y install httpd-tools"
echo "设置账号密码>>> htpasswd -cd ./passwords squid"
echo "提示输入密码>>> 自己设置密码"
echo "参照./squid.conf 修改配置文件 vim /etc/squid/squid.conf"
echo "systemctl start squid.service"
echo ''
echo ''
echo '=====Linux设置全局网络代理方法======='
echo "编辑系统环境变量文件 vim /etc/profile"
echo "以下内容拷贝至文件尾部："
echo '#proxy格式: http://账号:密码@IP:端口'
echo 'export http_proxy="http://squid:squid@43.138.255.110:3128"'
echo 'export https_proxy="http://squid:squid@43.138.255.110:3128"'
echo '#export ftp_proxy="http://squid:squid@43.138.255.110:3128"'
echo '#设置不使用代理的IP'
echo 'export no_proxy="localhost,127.0.0.1"'
echo ''
echo '使修改的配置立即生效  source /etc/profile   (如果还是不生效只能重启系统 reboot)'
echo ''
echo ''
echo '=====Window设置全局网络代理方法======'
echo "右下角网络图标右键-打开 网络和Internet设置-代理-手动设置代理"