docker run -d \
  --name nginx \
  --restart unless-stopped \
  -p 80:80 \
  -p 443:443 \
  -v ~/nginx/html:/usr/share/nginx/html:ro \
  -v ~/nginx/conf.d:/etc/nginx/conf.d:ro \
  -v ~/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v ~/nginx/logs:/var/log/nginx \
  nginx:latest