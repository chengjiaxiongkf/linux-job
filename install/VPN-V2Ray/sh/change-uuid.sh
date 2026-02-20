#!/bin/bash
# V2Ray UUID 修改工具

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 配置文件路径
CONFIG_FILE="/usr/local/etc/v2ray/config.json"
INFO_FILE="/root/v2ray-config.txt"

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}[ERROR] 请使用 root 用户或 sudo 权限运行此脚本${NC}"
    exit 1
fi

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}[ERROR] 配置文件未找到: $CONFIG_FILE${NC}"
    echo "请确认 V2Ray 是否已正确安装"
    exit 1
fi

echo -e "${GREEN}==== V2Ray UUID 修改工具 ====${NC}"
echo ""

# 读取当前 UUID
CURRENT_UUID=$(grep '"id":' "$CONFIG_FILE" | head -n 1 | awk -F '"' '{print $4}')
echo "当前 UUID: $CURRENT_UUID"
echo ""

# 选择模式
echo "请选择 UUID 生成方式:"
echo "1. 自动生成随机 UUID (默认)"
echo "2. 手动输入自定义 UUID"
read -p "请输入选项 [1-2]: " CHOICE

if [ "$CHOICE" == "2" ]; then
    while true; do
        read -p "请输入自定义 UUID: " NEW_UUID
        # 简单验证 UUID 格式
        if [[ "$NEW_UUID" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
            break
        else
            echo -e "${RED}[ERROR] UUID 格式不正确，请重新输入${NC}"
            echo "正确格式示例: 12345678-1234-1234-1234-1234567890ab"
        fi
    done
else
    # 生成新 UUID
    if command -v uuidgen &> /dev/null; then
        NEW_UUID=$(uuidgen)
    else
        NEW_UUID=$(cat /proc/sys/kernel/random/uuid)
    fi
fi

echo "即将使用的新 UUID: $NEW_UUID"
echo ""

read -p "确认要修改 UUID 吗? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "已取消修改"
    exit 0
fi

echo ""
echo "正在修改配置文件..."

# 修改 config.json
# 使用 sed 替换 UUID (注意这里假设 id 字段格式比较标准)
sed -i "s/\"id\": \"$CURRENT_UUID\"/\"id\": \"$NEW_UUID\"/g" "$CONFIG_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS] 配置文件修改成功${NC}"
else
    echo -e "${RED}[ERROR] 配置文件修改失败${NC}"
    exit 1
fi

# 重启 V2Ray 服务
echo "正在重启 V2Ray 服务..."
systemctl restart v2ray

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS] V2Ray 服务重启成功${NC}"
else
    echo -e "${RED}[ERROR] V2Ray 服务重启失败${NC}"
    echo "请检查服务状态: systemctl status v2ray"
fi

# 更新信息文件 (如果存在)
if [ -f "$INFO_FILE" ]; then
    echo "正在更新配置信息文件 ($INFO_FILE)..."
    sed -i "s/$CURRENT_UUID/$NEW_UUID/g" "$INFO_FILE"
    echo -e "${GREEN}[SUCCESS] 配置信息文件已更新${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}UUID 修改完成!${NC}"
echo "------------------------------------------"
echo "新 UUID: $NEW_UUID"
echo "------------------------------------------"
echo "请记得更新您的客户端配置 (V2RayN / V2RayNG / Clash 等)"
echo "=========================================="
