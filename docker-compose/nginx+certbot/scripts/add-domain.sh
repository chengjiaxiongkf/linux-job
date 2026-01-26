
#!/bin/bash

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查参数
if [ $# -lt 1 ]; then
    echo -e "${RED}用法: $0 <域名> [其他域名...]${NC}"
    echo "示例: $0 example.com www.example.com api.example.com"
    exit 1
fi

DOMAINS="$@"
PRIMARY_DOMAIN="$1"
CERTBOT_WWW="/var/www/certbot"
LETSENCRYPT_DIR="/etc/letsencrypt"

# 1. 为域名创建目录结构
echo -e "${YELLOW}[1/5] 创建目录结构...${NC}"
mkdir -p "html/${PRIMARY_DOMAIN}"
mkdir -p "nginx/conf.d"

# 2. 创建Nginx配置模板
echo -e "${YELLOW}[2/5] 创建Nginx配置...${NC}"
cat > "nginx/conf.d/${PRIMARY_DOMAIN}.conf" << EOF
# HTTP配置 - 用于证书申请
server {
    listen 80;
    server_name ${DOMAINS};
    
    location /.well-known/acme-challenge/ {
        root ${CERTBOT_WWW};
        try_files \$uri =404;
    }
    
    location / {
        return 301 https://\$host\$request_uri;
    }
}

# HTTPS配置 - 申请证书后取消注释
# server {
#     listen 443 ssl http2;
#     server_name ${DOMAINS};
#     
#     ssl_certificate ${LETSENCRYPT_DIR}/live/${PRIMARY_DOMAIN}/fullchain.pem;
#     ssl_certificate_key ${LETSENCRYPT_DIR}/live/${PRIMARY_DOMAIN}/privkey.pem;
#     include /etc/nginx/conf.d/ssl-common.conf;
#     
#     root /usr/share/nginx/html/${PRIMARY_DOMAIN};
#     index index.html index.htm;
#     
#     location / {
#         try_files \$uri \$uri/ =404;
#     }
#     
#     # 代理配置示例
#     # location /api/ {
#     #     proxy_pass http://backend:3000;
#     #     proxy_set_header Host \$host;
#     #     proxy_set_header X-Real-IP \$remote_addr;
#     # }
# }
EOF

# 3. 创建默认首页
echo -e "${YELLOW}[3/5] 创建默认页面...${NC}"
cat > "html/${PRIMARY_DOMAIN}/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>${PRIMARY_DOMAIN}</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #333; }
        .status { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <h1>欢迎访问 ${PRIMARY_DOMAIN}</h1>
    <p>SSL证书状态: <span class="status">待配置</span></p>
    <p>HTTPS配置完成后，这里会显示安全连接状态。</p>
</body>
</html>
EOF

# 4. 申请SSL证书
echo -e "${YELLOW}[4/5] 申请SSL证书...${NC}"
docker compose restart nginx

# 等待Nginx启动
sleep 3

# 运行Certbot申请证书
docker compose run --rm certbot certonly \
    --webroot \
    --webroot-path=${CERTBOT_WWW} \
    --email admin@${PRIMARY_DOMAIN} \
    --agree-tos \
    --no-eff-email \
    --expand \
    -d ${DOMAINS}

if [ $? -eq 0 ]; then
    echo -e "${GREEN}证书申请成功！${NC}"
    
    # 5. 启用HTTPS配置
    echo -e "${YELLOW}[5/5] 启用HTTPS配置...${NC}"
    sed -i 's|^# \(server {.*listen 443.*\)|\1|' "nginx/conf.d/domains/${PRIMARY_DOMAIN}.conf"
    
    # 重载Nginx配置
    docker compose exec nginx nginx -s reload
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}域名 ${PRIMARY_DOMAIN} 配置完成！${NC}"
    echo -e "${GREEN}附加域名: ${@:2}${NC}"
    echo -e "${GREEN}证书位置: data/letsencrypt/live/${PRIMARY_DOMAIN}/${NC}"
    echo -e "${GREEN}网站目录: html/${PRIMARY_DOMAIN}/${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${RED}证书申请失败，请检查：${NC}"
    echo "1. 域名解析是否正确"
    echo "2. 80端口是否开放"
    echo "3. 防火墙设置"
    exit 1
fi