#!/bin/bash

# RustDesk 一键部署脚本（适用于docker-compose/rustdesk目录）
# 支持Ubuntu/Debian/CentOS系统

set -e

echo "=== RustDesk Docker 一键部署脚本 ==="
echo "注意：请确保在 docker-compose/rustdesk 目录下运行此脚本"
echo

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo "请使用root用户运行此脚本"
   exit 1
fi

# 检测操作系统
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    echo "无法检测操作系统"
    exit 1
fi

echo "检测到操作系统: $OS $VER"

# 检查是否在正确的目录
if [[ ! -f "docker-compose.yml" ]]; then
    echo "错误：请在 docker-compose/rustdesk 目录下运行此脚本"
    echo "当前目录: $(pwd)"
    echo "请执行: cd docker-compose/rustdesk"
    exit 1
fi

# 安装Docker和Docker Compose（如果未安装）
install_docker() {
    echo "正在检查Docker环境..."
    
    if ! command -v docker &> /dev/null; then
        echo "Docker未安装，正在安装..."
        
        case $OS in
            ubuntu|debian)
                apt-get update
                apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
                curl -fsSL https://download.docker.com/linux/$OS/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$OS $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
                apt-get update
                apt-get install -y docker-ce docker-ce-cli containerd.io
                ;;
            centos|rhel|fedora)
                yum install -y yum-utils
                yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                yum install -y docker-ce docker-ce-cli containerd.io
                ;;
            *)
                echo "不支持的操作系统"
                exit 1
                ;;
        esac
        
        # 启动Docker服务
        systemctl start docker
        systemctl enable docker
        
        # 安装Docker Compose
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        
        echo "Docker安装完成"
    else
        echo "Docker已安装，版本: $(docker --version)"
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo "Docker Compose未安装，正在安装..."
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        echo "Docker Compose安装完成"
    else
        echo "Docker Compose已安装，版本: $(docker-compose --version)"
    fi
}

# 配置防火墙
setup_firewall() {
    echo "正在配置防火墙..."
    
    case $OS in
        ubuntu|debian)
            if command -v ufw &> /dev/null; then
                echo "配置UFW防火墙..."
                ufw allow 80/tcp comment "RustDesk Web界面"
                ufw allow 443/tcp comment "RustDesk HTTPS"
                ufw allow 21114:21118/tcp comment "RustDesk服务端口"
                ufw allow 21116/udp comment "RustDesk UDP端口"
                echo "防火墙规则已添加"
            fi
            ;;
        centos|rhel|fedora)
            if command -v firewall-cmd &> /dev/null; then
                echo "配置firewalld防火墙..."
                firewall-cmd --permanent --add-port=80/tcp
                firewall-cmd --permanent --add-port=443/tcp
                firewall-cmd --permanent --add-port=21114-21118/tcp
                firewall-cmd --permanent --add-port=21116/udp
                firewall-cmd --reload
                echo "防火墙规则已添加"
            fi
            ;;
    esac
    
    echo "防火墙配置完成"
}

# 创建必要的目录
create_directories() {
    echo "正在创建必要的目录..."
    mkdir -p data ssl
    echo "目录创建完成"
}

# 启动服务
start_services() {
    echo "正在启动RustDesk服务..."
    
    # 拉取镜像
    echo "正在拉取Docker镜像..."
    docker-compose pull
    
    # 启动服务
    docker-compose up -d
    
    echo "等待服务启动..."
    sleep 15
    
    # 检查服务状态
    if docker-compose ps | grep -q "Up"; then
        echo "RustDesk服务启动成功！"
        
        # 显示服务状态
        echo
        echo "服务状态："
        docker-compose ps
    else
        echo "服务启动失败，请检查日志："
        docker-compose logs
        exit 1
    fi
}

# 获取访问信息
get_access_info() {
    echo "正在获取访问信息..."
    
    # 获取公网IP
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "无法获取公网IP")
    
    # 获取局域网IP
    LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "无法获取局域网IP")
    
    # 获取密钥
    echo "正在获取服务器密钥..."
    sleep 5
    KEY=$(docker-compose exec -T rustdesk-server cat /root/id_ed25519.pub 2>/dev/null || echo "密钥获取失败，请稍后手动获取")
    
    echo
    echo "=== RustDesk 部署完成 ==="
    echo
    echo "🌐 访问地址："
    echo "   局域网访问：http://$LOCAL_IP"
    echo "   公网访问：http://$PUBLIC_IP (如果服务器有公网IP)"
    echo
    echo "🔑 服务器密钥："
    echo "   $KEY"
    echo
    echo "📱 移动端访问："
    echo "   1. 手机浏览器访问：http://$LOCAL_IP"
    echo "   2. RustDesk APP服务器地址：$LOCAL_IP:21116"
    echo
    echo "📋 常用管理命令："
    echo "   查看状态：docker-compose ps"
    echo "   查看日志：docker-compose logs -f"
    echo "   停止服务：docker-compose down"
    echo "   重启服务：docker-compose restart"
    echo "   获取密钥：docker-compose exec rustdesk-server cat /root/id_ed25519.pub"
    echo
    echo "💾 数据备份："
    echo "   备份数据：tar -czf rustdesk-backup.tar.gz data/"
    echo "   恢复数据：tar -xzf rustdesk-backup.tar.gz"
    echo
    echo "📁 配置文件目录：$(pwd)"
    echo
    echo "⚠️  重要提示："
    echo "   - 请妥善保存服务器密钥"
    echo "   - 建议修改默认端口以提高安全性"
    echo "   - 定期备份data目录中的重要数据"
    echo
}

# 主函数
main() {
    echo "开始部署RustDesk服务..."
    
    # 安装Docker环境
    install_docker
    
    # 创建目录
    create_directories
    
    # 配置防火墙
    setup_firewall
    
    # 启动服务
    start_services
    
    # 显示访问信息
    get_access_info
}

# 运行主函数
main