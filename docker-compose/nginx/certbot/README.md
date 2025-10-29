# 生成证书
### webroot模式，需要在nginx的80端口下增加一个路由
    server {
        listen  80;
        server_name cjxhss.com;
        location ~ /.well-known/acme-challenge/ {
            root /etc/nginx/html;
            allow all;
        }
        # 其他所有请求重定向到 HTTPS
        location / {
            return 301 https://$server_name$request_uri;
        }
    }
###### 生成证书    
    sudo certbot certonly --webroot -w /data/volumes/nginx/html -d cjxhss.com
### 其他模式(待更新)
# 定时证书续期
### 增加一个每天凌晨2点执行的证书续期操作
    crontab -e
### Nginx如果在Docker容器中
    0 2 * * * /usr/bin/certbot renew --quiet --post-hook "docker exec nginx nginx -s reload"
### Nginx如果在宿主机中
    0 2 * * * /usr/bin/certbot renew --quiet --post-hook "nginx -s reload"