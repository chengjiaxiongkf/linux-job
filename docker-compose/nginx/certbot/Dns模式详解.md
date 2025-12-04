# Dns模式只能手工，不可以自动续期，每次申请证书都要改一遍DNS
### 让 Certbot 给出需要添加的 TXT 记录
```bash
    certbot certonly --manual --preferred-challenges dns \
    --email 514471552@qq.com --agree-tos \
    -d rdweb-oss.sampras.vip
```
会告诉你如何添加TXT记录，不要按回车！看下一步

### 另外开一个命令行，验证记录是否已生效
```bash
curl -s --connect-timeout 3 \
  "https://doh.pub/dns-query?name=_acme-challenge.rdweb-oss.sampras.vip&type=TXT" \
  -H "Accept: application/dns-json"
```

### 生效了之后回到第一步去按回车，Certbot 就会给你证书，如下
Before continuing, verify the record is deployed.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Press Enter to Continue
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/rdweb-oss.sampras.vip/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/rdweb-oss.sampras.vip/privkey.pem
   Your certificate will expire on 2026-03-04. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le

