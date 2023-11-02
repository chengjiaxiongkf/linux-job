#!/bin/sh
docker stop chatgpt-web-java && docker rm chatgpt-web-java 2>/dev/null
docker run -d -p 3002:3002 -e PROFILE_ENV=dev -e CHAT_OPENAI_API_BASE_URL=http://iabrc.cn/openai/ --restart always --name chatgpt-web-java registry.cn-zhangjiakou.aliyuncs.com/cjx_new/chatgpt-web-java:2023-08-28-19-31-50
