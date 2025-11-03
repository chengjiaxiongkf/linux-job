# Webroot模式
### 介绍
这个模式生成证书的时候会请求 http://你的域名/.well-known/acme-challenge/test 做一个验证，请求是404也没关系，只要你在80加个路由即可。
综上所述，所以生成证书的前提条件：
1. 域名解析到你的服务器IP
2. 服务器上已经启动了80端口的http服务
3. 80端口的解析路由含有
        location ~ /.well-known/acme-challenge/ {
            root /etc/nginx/html;
            allow all;
        }

使用Certbot生成证书后，证书会在宿主机的一个默认的目录上生成实际的两个证书文件
    
    /etc/letsencrypt/archive/域名/fullchain1.pem
    /etc/letsencrypt/archive/域名/privkey1.pem

并且生成两个linux系统的快捷方式link，这两个link会指向上面这两个证书文件
    
    /etc/letsencrypt/live/yjwl.sampras.vip/fullchain.pem
    /etc/letsencrypt/live/yjwl.sampras.vip/privkey.pem

### 上述操作的作用：
当你第二次生成证书的时候，文件名会变成 fullchain2.pem、privkey2.pem，link也会改变指向新的两个证书文件
当你第三次生成证书的时候，文件名会变成 fullchain3.pem、privkey3.pem，link也会改变指向新的两个证书文件
所以，你nginx配置里面使用下面这个link路径就是永远不会变化的。
/etc/letsencrypt/live/yjwl.sampras.vip/fullchain.pem
/etc/letsencrypt/live/yjwl.sampras.vip/privkey.pem

### 实际操作
1. 我是docker部署nginx的，我会把nginx容器映射/etc/letsencrypt 整个目录，在docker-compose.yml里面最后一行可以看到

2. 在nginx配置文件里面证书路径就用上面说的link路径，这样后续生成的证书通过一样是保持在这个link下，也就不用改变。

3. 当你生成过一次之后，最后是crontab定时任务
    
    crontab -e （跟vim用法一致）
    增加下面这行
    0 2 * * * /usr/bin/certbot renew --quiet --post-hook "docker exec nginx nginx -s reload"
    crontab -l （查看定时任务）

定时任务会在每天凌晨2点运行一次证书续期命令（Certbot之前生成过的证书全部都会跑一遍，但是有效期大于30天的证书会跳过处理）
--post-hook是生成证书后钩子函数，如果有证书变化，nginx需要重载