# 1. 初始化项目
chmod +x scripts/*.sh

# 2. 添加第一个域名
./scripts/add-domain.sh example.com www.example.com

# 3. 添加第二个域名（纯域名）
./scripts/add-domain.sh api.example.com

# 4. 查看所有域名
./scripts/list-domains.sh

# 5. 手动续期
./scripts/renew-all.sh

# 6. 监控证书
./scripts/monitor-certs.sh

# 7. 定时任务（添加到crontab）
# 每天凌晨3点检查续期
echo "0 3 * * * /data/linux-job-master/docker-compose/nginx+certbot/scripts/renew-all.sh >> /var/log/cert-renew.log 2>&1" | sudo crontab -
# 每周一检查过期情况
0 9 * * 1 /path/to/scripts/monitor-certs.sh >> /var/log/cert-monitor.log 2>&1