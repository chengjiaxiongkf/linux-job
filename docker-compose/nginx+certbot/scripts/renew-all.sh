#!/bin/bash

# 续期所有证书并重载Nginx
docker compose run --rm certbot renew --quiet

# 检查续期结果
if [ $? -eq 0 ]; then
    echo "$(date): 证书续期成功"
    docker compose exec nginx nginx -s reload
    echo "Nginx配置已重载"
else
    echo "$(date): 证书续期失败" >&2
    exit 1
fi