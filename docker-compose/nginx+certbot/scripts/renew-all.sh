#!/bin/bash

# 让 cron 也能找到 docker
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

# 切换到 docker-compose.yml 所在目录（脚本所在目录的上一级）
cd "$(dirname "$0")/.." || { echo "$(date): 无法进入项目目录" >&2; exit 1; }

echo "===== $(date): 开始证书续期 ====="

# 续期所有证书（去掉 --quiet 方便排查；如果稳定后想静默可加回）
docker compose run --rm certbot renew
RENEW_RC=$?

if [ $RENEW_RC -eq 0 ]; then
    echo "$(date): 证书续期命令执行成功"
    docker compose exec -T nginx nginx -s reload && echo "Nginx配置已重载" \
        || echo "$(date): Nginx reload 失败" >&2
else
    echo "$(date): 证书续期失败 (exit=$RENEW_RC)" >&2
    exit 1
fi