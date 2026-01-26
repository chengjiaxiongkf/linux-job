#!/bin/bash

# 检查证书过期时间
EXPIRY_THRESHOLD=30  # 提前30天警告

echo "检查证书过期情况..."
echo "========================="

docker-compose run --rm certbot certificates 2>/dev/null | \
grep -A3 "Certificate Name:" | \
while IFS= read -r line; do
    if [[ $line == *"Certificate Name:"* ]]; then
        DOMAIN=$(echo $line | cut -d: -f2 | xargs)
    elif [[ $line == *"Expiry Date:"* ]]; then
        EXPIRY_STR=$(echo $line | cut -d: -f2- | xargs)
        EXPIRY_DATE=$(date -d "$EXPIRY_STR" +%s)
        CURRENT_DATE=$(date +%s)
        DAYS_LEFT=$(( (EXPIRY_DATE - CURRENT_DATE) / 86400 ))
        
        if [ $DAYS_LEFT -le $EXPIRY_THRESHOLD ]; then
            echo "⚠️  警告: $DOMAIN 将在 $DAYS_LEFT 天后过期!"
            # 可以发送邮件通知
            # echo "证书 $DOMAIN 即将过期" | mail -s "证书过期警告" admin@example.com
        else
            echo "✓ $DOMAIN: $DAYS_LEFT 天后过期"
        fi
    fi
done