#!/usr/bin/env bash
set -e

#---------------------------------------------------
# Docker & Docker-Compose 一键安装脚本 (Ubuntu 20.04)
#---------------------------------------------------

echo "==== Step 1: 卸载旧版本（如有） ===="
sudo apt-get remove -y docker.io docker-doc docker-compose podman-docker containerd runc || true
sudo apt-get autoremove -y

echo "==== Step 2: 更新 apt 包索引 ===="
sudo apt-get update -y

echo "==== Step 3: 安装依赖 ===="
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

echo "==== Step 4: 添加 Docker 官方 GPG 密钥 ===="
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "==== Step 5: 设置仓库 ===="
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "==== Step 6: 安装 Docker Engine、CLI、containerd、Compose 插件 ===="
sudo apt-get update -y
sudo apt-get install -y \
  docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

echo "==== Step 7: 启动并设置开机自启 ===="
sudo systemctl enable --now docker

echo "==== Step 8: 将当前用户加入 docker 组（免 sudo） ===="
sudo usermod -aG docker "$USER"

echo "==== Step 9: 验证安装 ===="
sudo docker run --rm hello-world

echo "==== Step 10: 安装Docker compose ===="
apt  install docker-compose

echo "==== Step 11: 验证安装Docker compose ===="
docker-compose version

echo "------------------------------------------------"
echo "✅ Docker & Docker Compose 安装完成！"
echo "请注销并重新登录，以使免 sudo 权限生效。"
echo "------------------------------------------------"