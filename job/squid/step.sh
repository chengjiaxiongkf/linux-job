#!/bin/bash
echo "设置账号密码>>> htpasswd -cd ./passwords squid"
echo "提示输入密码>>> 自己设置密码"
echo "参照./squid.conf 修改配置文件 vim /etc/squid/squid.conf"
echo "systemctl start squid.service"