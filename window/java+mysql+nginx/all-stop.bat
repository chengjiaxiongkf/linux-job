@echo off
chcp 65001 >nul

REM 启动 MySQL
call D:\report\mysql-8.0.34-winx64\mysql-stop.bat

REM 启动 Nginx
start /B cmd /C D:\report\nginx-1.25.2\nginx-stop.bat