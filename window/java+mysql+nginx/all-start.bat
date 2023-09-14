@echo off
chcp 65001 >nul
REM 启动 MySQL
call D:\report\mysql-8.0.34-winx64\mysql-start.bat
REM 启动 Nginx
cd /d D:\report\nginx-1.25.2
start /B nginx.exe
REM 启动 Java
start /B cmd /C D:\report\java\java-start.bat