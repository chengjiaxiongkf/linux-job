#!/bin/bash

# V2Ray 一键安装脚本
# 基于 VLESS + WebSocket + TLS + Nginx 配置方案

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [ "$(id -u)" != "0" ]; then
        log_error "请使用 root 用户或 sudo 权限运行此脚本"
        exit 1
    fi
}

# 收集用户输入
collect_info() {
    log_info "==== V2Ray 部署配置向导 ===="
    echo ""

    # 重要提示
    log_warn "========== 重要提示 =========="
    log_warn "在继续之前,请确保您已完成以下操作:"
    log_warn "1. 已购买/准备好一个域名"
    log_warn "2. 已在域名 DNS 服务商处添加 A 类型解析记录"
    log_warn "3. 将域名解析到本服务器的公网 IP 地址"
    log_warn "4. DNS 解析已生效 (可通过 ping 域名验证)"
    echo ""
    log_info "如果DNS解析未配置或未生效,证书申请将会失败!"
    echo ""
    read -p "确认已完成 DNS 解析配置? (y/n): " DNS_CONFIRM
    if [ "$DNS_CONFIRM" != "y" ] && [ "$DNS_CONFIRM" != "Y" ]; then
        log_warn "请先配置 DNS 解析后再运行此脚本"
        exit 0
    fi
    echo ""

    # 域名
    read -p "请输入您的域名 (例如: ss.sampras.vip): " DOMAIN
    if [ -z "$DOMAIN" ]; then
        log_error "域名不能为空"
        exit 1
    fi

    # 验证DNS解析
    log_info "正在验证 DNS 解析..."

    # 获取服务器公网IP
    SERVER_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || curl -s ipinfo.io/ip)
    if [ -z "$SERVER_IP" ]; then
        log_warn "无法获取服务器公网 IP,跳过 DNS 验证"
    else
        log_info "本服务器 IP: $SERVER_IP"

        # 解析域名
        DOMAIN_IP=$(dig +short "$DOMAIN" @8.8.8.8 | tail -n1)

        if [ -z "$DOMAIN_IP" ]; then
            log_error "域名 $DOMAIN 无法解析"
            log_error "请检查 DNS 配置是否正确"
            read -p "是否继续安装? (y/n): " CONTINUE
            if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
                exit 1
            fi
        elif [ "$DOMAIN_IP" != "$SERVER_IP" ]; then
            log_warn "域名解析 IP ($DOMAIN_IP) 与服务器 IP ($SERVER_IP) 不匹配"
            log_warn "这可能导致证书申请失败"
            read -p "是否继续安装? (y/n): " CONTINUE
            if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
                exit 1
            fi
        else
            log_info "DNS 解析验证通过: $DOMAIN -> $SERVER_IP"
        fi
    fi
    echo ""

    # 邮箱
    read -p "请输入您的邮箱 (用于证书申请): " EMAIL
    if [ -z "$EMAIL" ]; then
        log_error "邮箱不能为空"
        exit 1
    fi

    # WebSocket 路径
    echo ""
    log_info "WebSocket 路径用于客户端连接时的路径参数"
    log_info "建议使用随机且不易猜测的路径以提高安全性"
    read -p "请输入 WebSocket 路径 (直接回车使用默认 /your_path): " WS_PATH
    WS_PATH=${WS_PATH:-/your_path}
    log_info "将使用路径: $WS_PATH"

    # V2Ray 本地监听端口
    echo ""
    log_info "V2Ray 本地监听端口 (仅监听 127.0.0.1,不对外暴露)"
    log_info "此端口用于 Nginx 反向代理到 V2Ray,建议使用 10000-65535 之间的端口"
    read -p "请输入 V2Ray 本地端口 (直接回车使用默认 10000): " V2RAY_PORT
    V2RAY_PORT=${V2RAY_PORT:-10000}

    # 验证端口号
    if ! [[ "$V2RAY_PORT" =~ ^[0-9]+$ ]] || [ "$V2RAY_PORT" -lt 1024 ] || [ "$V2RAY_PORT" -gt 65535 ]; then
        log_error "无效的端口号,请输入 1024-65535 之间的数字"
        exit 1
    fi

    log_info "将使用端口: $V2RAY_PORT"

    # 生成 UUID
    echo ""
    log_info "正在生成 UUID..."
    if command -v uuidgen &> /dev/null; then
        UUID=$(uuidgen)
    else
        UUID=$(cat /proc/sys/kernel/random/uuid)
    fi

    log_info "生成的 UUID: $UUID"

    echo ""
    log_info "==== 配置信息确认 ===="
    echo "域名: $DOMAIN"
    echo "邮箱: $EMAIL"
    echo "WebSocket 路径: $WS_PATH"
    echo "UUID: $UUID"
    echo "V2Ray 本地端口: $V2RAY_PORT"
    echo ""

    read -p "确认以上信息无误? (y/n): " CONFIRM
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        log_warn "用户取消安装"
        exit 0
    fi
}

# 安装依赖
install_dependencies() {
    log_info "更新系统包..."
    apt update -y

    log_info "安装必要工具..."
    apt install -y curl wget nginx socat dnsutils
}

# 安装 V2Ray
install_v2ray() {
    log_info "开始安装 V2Ray..."

    # 下载安装脚本
    INSTALL_SCRIPT="/tmp/v2ray-install.sh"
    if ! curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh -o "$INSTALL_SCRIPT"; then
        log_error "下载 V2Ray 安装脚本失败"
        log_warn "如果是报错v2ray-linux-64.zip网络问题，请手动下载并把v2ray-linux-64.zip放到 /tmp/v2ray-linux-64.zip 后重新运行"
        exit 1
    fi

    # 执行安装
    bash "$INSTALL_SCRIPT"

    log_info "V2Ray 安装完成"
}

# 安装 acme.sh
install_acme() {
    log_info "安装 acme.sh 证书管理工具..."

    if [ ! -d "$HOME/.acme.sh" ]; then
        curl https://get.acme.sh | sh
        source ~/.bashrc
    else
        log_warn "acme.sh 已安装,跳过"
    fi
}

# 启动 Nginx
start_nginx() {
    log_info "启动 Nginx..."
    systemctl start nginx
    systemctl enable nginx
}

# 申请 SSL 证书
request_certificate() {
    log_info "开始申请 SSL 证书..."

    # 确保 webroot 目录存在
    mkdir -p /var/www/html

    # 注册 acme.sh 账户
    if [ ! -f "$HOME/.acme.sh/account.conf" ]; then
        ~/.acme.sh/acme.sh --register-account -m "$EMAIL"
    fi

    # 申请证书
    log_info "申请域名 $DOMAIN 的证书..."
    ~/.acme.sh/acme.sh --issue -d "$DOMAIN" --webroot /var/www/html

    # 重启 Nginx
    systemctl restart nginx

    # 创建证书目录
    mkdir -p /etc/v2ray/

    # 安装证书
    log_info "安装证书到 /etc/v2ray/..."
    ~/.acme.sh/acme.sh --installcert -d "$DOMAIN" \
        --key-file /etc/v2ray/v2ray.key \
        --fullchain-file /etc/v2ray/v2ray.crt \
        --reloadcmd "systemctl restart v2ray"

    log_info "SSL 证书申请完成"
}

# 配置 V2Ray
configure_v2ray() {
    log_info "配置 V2Ray..."

    # 备份原配置
    if [ -f /usr/local/etc/v2ray/config.json ]; then
        mv /usr/local/etc/v2ray/config.json /usr/local/etc/v2ray/config.json.bak
    fi

    # 创建新配置
    cat > /usr/local/etc/v2ray/config.json <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": ${V2RAY_PORT},
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "level": 0
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "${WS_PATH}"
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
EOF

    log_info "V2Ray 配置完成"
}

# 配置 Nginx
configure_nginx() {
    log_info "配置 Nginx 反向代理..."

    # 备份原配置
    if [ -f /etc/nginx/sites-enabled/default ]; then
        mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.bak
    fi

    # 创建新配置
    cat > /etc/nginx/sites-enabled/default <<EOF
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    ssl_certificate       /etc/v2ray/v2ray.crt;
    ssl_certificate_key   /etc/v2ray/v2ray.key;
    ssl_protocols         TLSv1.2 TLSv1.3;
    ssl_ciphers           HIGH:!aNULL:!MD5;
    server_name           ${DOMAIN};

    # V2Ray WebSocket 转发配置
    location ${WS_PATH} {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:${V2RAY_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

        # 禁用缓存
        proxy_buffering off;
    }

    # 443 端口其他流量的 Fallback (用于伪装成一个正常的网站)
    location / {
        root /var/www/html;
        index index.html;
    }
}

server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};
    return 301 https://\$host\$request_uri;
}
EOF

    # 测试配置
    log_info "测试 Nginx 配置..."
    nginx -t

    # 重启 Nginx
    systemctl restart nginx

    log_info "Nginx 配置完成"
}

# 启动 V2Ray
start_v2ray() {
    log_info "启动 V2Ray 服务..."
    systemctl start v2ray
    systemctl enable v2ray

    log_info "V2Ray 服务已启动并设置为开机自启"
}

# 配置防火墙
configure_firewall() {
    log_info "配置防火墙规则..."

    # 检查是否安装了 ufw
    if command -v ufw &> /dev/null; then
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw allow 22/tcp
        log_info "已通过 ufw 开放 80, 443, 22 端口"
    # 检查是否安装了 firewalld
    elif command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        firewall-cmd --permanent --add-service=ssh
        firewall-cmd --reload
        log_info "已通过 firewalld 开放 80, 443, 22 端口"
    else
        log_warn "未检测到防火墙,请手动开放 80 和 443 端口"
    fi
}

# 显示配置信息
show_config() {
    echo ""
    echo "======================================"
    log_info "V2Ray 安装完成!"
    echo "======================================"
    echo ""
    echo "客户端配置信息:"
    echo "----------------------------------------"
    echo "协议 (Protocol): VLESS"
    echo "地址 (Address): $DOMAIN"
    echo "端口 (Port): 443"
    echo "UUID: $UUID"
    echo "传输协议 (Transport): WebSocket (ws)"
    echo "路径 (Path): $WS_PATH    ← 在客户端填写此路径"
    echo "TLS: 启用"
    echo "----------------------------------------"
    echo ""
    log_info "请在 V2Ray 客户端使用以上信息进行连接"
    log_warn "注意: WebSocket 路径 ($WS_PATH) 必须在客户端配置中正确填写"
    echo ""

    # 保存配置到文件
    cat > /root/v2ray-config.txt <<EOF
V2Ray 配置信息
生成时间: $(date)

========== 客户端配置参数 ==========
协议: VLESS
地址: $DOMAIN
端口: 443
UUID: $UUID
传输协议: WebSocket (ws)
WebSocket 路径: $WS_PATH  ← 重要!客户端必须填写此路径
TLS: 启用

【使用说明】
在 V2Ray 客户端 (V2RayN/V2RayNG/Clash 等) 中:
1. 选择协议为 VLESS
2. 地址填写: $DOMAIN
3. 端口填写: 443
4. UUID 填写: $UUID
5. 传输协议选择: WebSocket (ws)
6. WebSocket 路径填写: $WS_PATH (不要遗漏)
7. 启用 TLS
8. 连接测试成功后即可使用

服务管理命令:
- 启动: systemctl start v2ray
- 停止: systemctl stop v2ray
- 重启: systemctl restart v2ray
- 状态: systemctl status v2ray
- 日志: journalctl -u v2ray -f

Nginx 管理命令:
- 启动: systemctl start nginx
- 停止: systemctl stop nginx
- 重启: systemctl restart nginx
- 状态: systemctl status nginx
- 测试配置: nginx -t

配置文件位置:
- V2Ray: /usr/local/etc/v2ray/config.json
- Nginx: /etc/nginx/sites-enabled/default
- 证书: /etc/v2ray/v2ray.crt
- 私钥: /etc/v2ray/v2ray.key
EOF

    log_info "配置信息已保存到 /root/v2ray-config.txt"
}

# 主函数
main() {
    log_info "V2Ray 一键安装脚本"
    echo ""

    check_root
    collect_info

    install_dependencies
    install_v2ray
    install_acme
    start_nginx
    request_certificate
    configure_v2ray
    configure_nginx
    start_v2ray
    configure_firewall
    show_config

    log_info "安装完成!"
}

# 运行主函数
main
