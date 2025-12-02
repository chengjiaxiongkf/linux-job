# RustDesk Docker 一键部署指南

## 快速开始

### 1. 准备工作
- 安装 Docker 和 Docker Compose
- 确保服务器开放以下端口：
  - TCP: 80, 443, 21114, 21115, 21116, 21118
  - UDP: 21116

### 2. 部署步骤

```bash
# 1. 进入rustdesk目录
cd docker-compose/rustdesk

# 2. 修改环境配置
cp .env.example .env  # 如果存在示例文件
# 编辑 .env 文件，设置你的服务器IP或域名

# 3. 启动服务
docker-compose up -d

# 4. 查看状态
docker-compose ps

# 5. 查看日志
docker-compose logs -f
```

### 3. 获取密钥

部署完成后，获取服务器密钥：
```bash
docker-compose exec rustdesk-server cat /root/id_ed25519.pub
```

## 客户端配置

### 桌面客户端配置
1. 下载 RustDesk 客户端
2. 在设置中配置自建服务器：
   - ID服务器：你的服务器IP或域名
   - 中继服务器：你的服务器IP或域名
   - 密钥：使用上面获取的密钥

### 移动端访问

#### 方案一：使用Web界面（推荐）
1. 在手机浏览器访问：http://你的服务器IP
2. 登录Web界面进行远程控制

#### 方案二：使用RustDesk移动端APP
1. 下载RustDesk移动端APP
2. 在APP设置中配置自建服务器：
   - 服务器地址：你的服务器IP或域名:21116
   - 密钥：使用上面获取的密钥

## 目录结构
```
docker-compose/rustdesk/
├── docker-compose.yml    # Docker Compose配置
├── nginx.conf           # Nginx反向代理配置
├── .env                 # 环境变量配置
└── data/                # 数据持久化目录
    ├── id_ed25519       # 私钥文件
    └── id_ed25519.pub   # 公钥文件
```

## 常用命令

```bash
# 启动服务（在rustdesk目录下执行）
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看日志
docker-compose logs -f [service_name]

# 更新镜像
docker-compose pull
docker-compose up -d

# 备份数据
tar -czf rustdesk-backup.tar.gz data/

# 恢复数据
tar -xzf rustdesk-backup.tar.gz
```

## 安全建议

1. **修改默认端口**：建议修改默认的21114-21118端口
2. **启用HTTPS**：配置SSL证书，使用HTTPS访问
3. **设置防火墙**：只开放必要的端口
4. **定期备份**：定期备份data目录中的重要数据
5. **更新维护**：定期更新Docker镜像和系统补丁

## 故障排查

### 服务无法启动
```bash
# 检查端口占用
netstat -tulnp | grep -E '2111[4-8]|80|443'

# 查看详细日志
docker-compose logs rustdesk-server
docker-compose logs rustdesk-web
```

### 连接失败
1. 检查服务器端口是否开放
2. 确认防火墙设置
3. 验证密钥是否正确
4. 检查网络连通性

### 性能优化
- 增加服务器带宽
- 调整Docker资源限制
- 使用SSD存储提高IO性能

## 移动端Web访问优化

### 响应式设计
Nginx配置已针对移动设备优化，支持：
- 触摸操作
- 手势控制
- 自适应屏幕尺寸
- 移动端键盘支持

### 网络要求
- 建议WiFi环境使用，确保稳定连接
- 移动数据网络也可使用，但注意流量消耗
- 局域网内访问速度最快

## 技术支持

如有问题，请检查：
1. Docker服务状态：`systemctl status docker`
2. 容器运行状态：`docker-compose ps`
3. 网络连通性：`telnet 服务器IP 21116`
4. 查看日志获取详细错误信息