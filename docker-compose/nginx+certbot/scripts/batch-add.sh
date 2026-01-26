#!/bin/bash

# 从文件批量添加域名
DOMAIN_FILE="domains.txt"

if [ ! -f "$DOMAIN_FILE" ]; then
    echo "创建示例域名文件: $DOMAIN_FILE"
    cat > "$DOMAIN_FILE" << EOF
# 每行一个域名或域名组（空格分隔）
example.com www.example.com
api.example.com
blog.example.com

another-domain.com www.another-domain.com
EOF
    echo "请编辑 $DOMAIN_FILE 后重新运行脚本"
    exit 0
fi

echo "开始批量添加域名..."
echo "===================="

while IFS= read -r line; do
    # 跳过空行和注释
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    
    echo "添加: $line"
    ./scripts/add-domain.sh $line
    echo ""
    sleep 5  # 避免速率限制
done < "$DOMAIN_FILE"

echo "批量添加完成！"