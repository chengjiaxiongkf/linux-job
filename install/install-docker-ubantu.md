# 🚀 部署Docker
在Ubuntu 22.04.5 LTS上部署Dify是一个高效搭建AI应用开发平台的方法。

1.  **更新系统**：首先确保您的系统是最新的。
    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

2.  **安装Docker**：Dify依赖于Docker环境。
    ```bash
    sudo apt install -y docker.io
    sudo systemctl enable docker && sudo systemctl start docker
    ```

3.  **安装Docker Compose**：您需要安装Docker Compose来编排多容器服务。建议安装较新的版本（如V2）。
    ```bash
    sudo curl -SL https://github.com/docker/compose/releases/download/v2.25.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ```
    安装后，可以通过 `docker --version` 和 `docker-compose --version` 验证安装是否成功。

4.  **（可选但推荐）配置Docker镜像加速器**：为了提升拉取Docker镜像的速度，特别是国内网络环境，建议配置镜像加速器。编辑 `/etc/docker/daemon.json` 文件（如果文件不存在则新建），并添加镜像源。
    ```json
    {
      "registry-mirrors": [
        "https://docker.m.daocloud.io",
        "https://mirror.baidubce.com",
        "https://docker.nju.edu.cn"
      ]
    }
    ```
    配置完成后，重启Docker服务使配置生效：`sudo systemctl daemon-reload && sudo systemctl restart docker`。