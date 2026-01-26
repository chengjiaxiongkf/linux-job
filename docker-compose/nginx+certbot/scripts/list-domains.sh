#!/bin/bash

echo "=== 已配置的SSL域名 ==="
echo ""

# 列出所有证书
docker-compose run --rm certbot certificates 2>/dev/null | grep -A2 "Certificate Name:" | \
while IFS= read -r line; do
    if [[ $line == *"Certificate Name:"* ]]; then
        DOMAIN=$(echo $line | cut -d: -f2 | xargs)
        echo "主域名: $DOMAIN"
    elif [[ $line == *"Domains:"* ]]; then
        echo "包含域名: $(echo $line | cut -d: -f2 | xargs)"
    elif [[ $line == *"Expiry Date:"* ]]; then
        EXPIRY=$(echo $line | cut -d: -f2- | xargs)
        echo "过期时间: $EXPIRY"
        echo "---"
    fi
done

echo ""
echo "=== Nginx配置的域名 ==="
grep -h "server_name" nginx/conf.d/domains/*.conf 2>/dev/null | \
sed 's/server_name//g; s/;//g; s/^\s*//; s/\s*$//' | tr ' ' '\n' | sort -u