# 增加一个每天凌晨2点执行的证书续期操作
    crontab -e
### Nginx如果在Docker容器中
    0 2 * * * /usr/bin/certbot renew --quiet --post-hook "docker exec nginx nginx -s reload"

### Nginx如果在宿主机中
    0 2 * * * /usr/bin/certbot renew --quiet --post-hook "nginx -s reload"