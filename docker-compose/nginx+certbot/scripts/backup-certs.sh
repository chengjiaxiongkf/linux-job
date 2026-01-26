#!/bin/bash

BACKUP_DIR="./backups/certs-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "备份证书到: $BACKUP_DIR"
cp -r ./data/letsencrypt "$BACKUP_DIR/"
cp -r ./nginx/conf.d "$BACKUP_DIR/nginx-configs"

# 创建恢复脚本
cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash
echo "恢复证书..."
cp -r ./letsencrypt/* /path/to/your/project/data/letsencrypt/
echo "恢复Nginx配置..."
cp -r ./nginx-configs/* /path/to/your/project/nginx/conf.d/
echo "请重启Nginx: docker-compose restart nginx"
EOF

chmod +x "$BACKUP_DIR/restore.sh"

echo "备份完成！"