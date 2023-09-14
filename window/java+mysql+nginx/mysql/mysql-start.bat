@echo off
chcp 65001 >nul
echo 检查 MySQL 服务是否存在
set service=mysql
sc query %service% >nul 2>nul
if %errorlevel% == 1060 (
    echo %service% 服务不存在，开始安装！
    echo 初始化 %service%
    D:\report\mysql-8.0.34-winx64\bin\mysqld --initialize-insecure --console
    echo 安装 %service%
    D:\report\mysql-8.0.34-winx64\bin\mysqld -install mysql
    echo 启动 %service%
    net start mysql
    echo 连接 %service% 修改初始密码，首次登陆密码为 回车
    D:\report\mysql-8.0.34-winx64\bin\mysql -u root -p -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'VtU8XAd28UZd4xZBYMJUtbDFdK5ssgUc';"
) else (
    echo %service% 服务已经存在，正在启动...
    net start %service%
)
PAUSE