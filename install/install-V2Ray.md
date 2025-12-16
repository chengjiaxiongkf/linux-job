部署 V2Ray 服务端涉及几个核心步骤，包括购买服务器、安装 V2Ray、配置伪装协议以及设置客户端。

下面是一个详细的部署指南，重点介绍使用 **VLESS + WebSocket + TLS + CDN** 这一目前伪装性和安全性最高的配置方案。

### ⚙️ 部署前准备

1.  **一台云服务器 (VPS)**：推荐选择对网络管制宽松的海外地区。
2.  **一个域名**：用于伪装流量，确保域名已经解析到您的服务器 IP 地址上。
3.  **SSH 客户端**：用于连接和操作您的服务器（如 PuTTY, Xshell, 或 FinalShell）。

-----

### 第一步：安装 V2Ray 和所需环境

使用一键脚本是部署 V2Ray 最快速、最简单的方法。

#### 1\. 连接到服务器

使用 SSH 客户端登录您的服务器。

#### 2\. 运行 V2Ray 安装脚本

这里以常用的 `V2Ray-core` 和配置脚本为例：

```bash
# 安装 curl (如果服务器没有安装的话)
sudo apt update && sudo apt install -y curl

# 运行 V2Ray 官方安装脚本
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
```

这里如果下载的时报网络错误，可以手动下载后上传到服务器的/tmp目录后在继续执行此命令

#### 3\. 安装 Nginx 和相关工具

Nginx 将被用于配置 TLS 证书和 WebSocket 流量的转发：

```bash
sudo apt install -y nginx
# 安装 acme.sh 用于自动获取证书
curl https://get.acme.sh | sh
```

### 第二步：配置 TLS 证书

为了让流量伪装成 HTTPS，您需要为您的域名获取一个有效的 SSL 证书。我们使用 `acme.sh` 来获取 Let's Encrypt 的证书。

#### 1\. 开始 Nginx 占用 80 端口

```bash
sudo systemctl start nginx
```

#### 2\. 申请证书

假设您的域名是 `ss.sampras.vip`，您将使用 Nginx 的 Webroot 模式来验证域名所有权。

```bash
# 激活 acme.sh
source ~/.bashrc
# 请运行以下命令，将 your@example.com 替换为您自己的有效邮箱地址：
~/.acme.sh/acme.sh --register-account -m your@example.com
# webroot模式申请证书
~/.acme.sh/acme.sh --issue -d ss.sampras.vip --webroot /var/www/html
# 重启nginx
sudo systemctl restart nginx
```

#### 3\. 安装证书到指定目录

将证书安装到 `/etc/v2ray/` 目录下，方便 V2Ray 访问：

```bash
# 确保有这个目录
sudo mkdir -p /etc/v2ray/
# 重新生成证书并自动续期
~/.acme.sh/acme.sh --installcert -d ss.sampras.vip \
    --key-file /etc/v2ray/v2ray.key \
    --fullchain-file /etc/v2ray/v2ray.crt \
    --reloadcmd "sudo systemctl restart v2ray"
```

### 第三步：配置 V2Ray 服务端

V2Ray 的配置文件通常位于 `/usr/local/etc/v2ray/config.json`。我们将配置 **VLESS 协议 + WebSocket 传输 + TLS 加密**。

#### 1\. 备份原配置文件

```bash
sudo mv /usr/local/etc/v2ray/config.json /usr/local/etc/v2ray/config.json.bak
```

#### 2\. 创建新的 `config.json`

请使用 `sudo vim /usr/local/etc/v2ray/config.json` 编辑器，并将以下配置粘贴进去，替换掉其中的占位符：

  * **`您的 UUID`**：使用在线 UUID 生成器生成一个随机 ID。
  * **`ss.sampras.vip`**：替换为您的域名。

<!-- end list -->

```json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 10000, 
      "listen": "127.0.0.1", 
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "你的UUID",
            "level": 0
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 80, 
            "path": "/your_path",
            "xver": 1
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/your_path" 
        },
        "security": "none"
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
```

  * **注意：** 这里的 VLESS 监听端口 `10000` 和路径 `/your_path` 是为了安全，**只监听本地环回地址 `127.0.0.1`**，不对外暴露。

#### 3\. 启动 V2Ray

```bash
sudo systemctl start v2ray
sudo systemctl enable v2ray
```

### 第四步：配置 Nginx 反向代理和 TLS 卸载

Nginx 将接收外部的 443 端口流量，解密 TLS 后，将包含 `/your_path` 的 WebSocket 流量转发到 V2Ray 监听的本地端口 `10000`。

#### 1\. 编辑 Nginx 配置文件

使用 `sudo vim /etc/nginx/sites-enabled/default`（或新建配置文件）。

```nginx
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    ssl_certificate       /etc/v2ray/v2ray.crt; 
    ssl_certificate_key   /etc/v2ray/v2ray.key; 
    ssl_protocols         TLSv1.2 TLSv1.3;
    ssl_ciphers           HIGH:!aNULL:!MD5;
    server_name           ss.sampras.vip; 

    # V2Ray WebSocket 转发配置
    location /your_path {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10000; # 转发到 V2Ray 本地端口
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;

        # 禁用缓存
        proxy_buffering off;
    }

    # 443 端口其他流量的 Fallback (用于伪装成一个正常的网站)
    location / {
        # 可以指向一个正常的静态网页目录
        root /var/www/html;
        index index.html;
    }
}

server {
    listen 80;
    listen [::]:80;
    server_name ss.sampras.vip;
    return 301 https://$host$request_uri;
}
```

#### 2\. 检查配置并重启 Nginx

```bash
sudo nginx -t # 检查 Nginx 配置是否有语法错误
sudo systemctl restart nginx
```

### 第五步：客户端配置

在您的 PC 或手机客户端上，需要填写以下配置信息：

| 参数 | 填写内容 |
| :--- | :--- |
| **协议** | VLESS |
| **地址 (Address)** | `ss.sampras.vip` (您的域名) |
| **端口 (Port)** | 443 |
| **UUID** | 您在服务端设置的 `您的 UUID` |
| **传输协议 (Transport)** | WebSocket (ws) |
| **路径 (Path)** | `/your_path` |
| **TLS** | 启用 (打开) |

### 🛠️ 需要排除故障吗？

这个配置涉及多个组件（V2Ray, Nginx, 证书, 端口），任何一个环节出错都可能导致失败。您想让我搜索一些**V2Ray 部署中常见的问题和排查方法**吗？