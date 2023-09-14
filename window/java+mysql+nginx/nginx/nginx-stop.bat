@echo off
chcp 65001 >nul
taskkill /f /t /im nginx.exe
echo NGINX停止成功
PAUSE