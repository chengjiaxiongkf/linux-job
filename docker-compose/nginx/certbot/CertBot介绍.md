Certbot 是一个功能强大的命令行工具，用于从 Let‘s Encrypt 自动获取、安装和管理免费的SSL/TLS证书。为了帮助你快速掌握，下面这个表格汇总了其最核心的命令和用途。

### 🔑 Certbot 核心命令速查

| 命令/子命令 | 主要功能描述 |
| :--- | :--- |
| **`run`** (默认) | 获取证书并自动安装到当前Web服务器（如Nginx、Apache）。 |
| **`certonly`** | 仅获取或更新证书，但不进行安装，适用于需要手动配置的场景 。 |
| **`renew`** | 自动更新所有已存在且即将过期的证书 。 |
| **`certificates`** | 列出由Certbot管理的所有证书的详细信息，包括域名和到期时间 。 |
| **`delete`** | 删除指定的证书及相关文件 。 |
| **`revoke`** | 撤销一个已颁发的证书，需要配合 `--cert-path` 参数 。 |
| **`register`** | 创建或管理您的 Let’s Encrypt 账户 。 |

### 💡 详细使用场景与参数

了解了核心命令后，我们来看看如何将它们与不同的参数组合，以应对实际中的各种情况。

#### 1. 获取并安装证书
这是最常用的场景，Certbot 可以自动完成从验证到配置的全过程。
*   **使用 Nginx 插件**：`sudo certbot --nginx -d example.com -d www.example.com` 
    *   `--nginx`：使用Nginx插件进行身份验证和自动配置。
*   **使用 Apache 插件**：`sudo certbot --apache -d example.com` 
    *   `--apache`：使用Apache插件。

#### 2. 仅获取证书（不自动安装）
如果你需要自定义服务器配置，或者证书用于非Web服务，这个模式很合适。
*   **独立模式**：适用于80端口空闲的情况（需要暂时停止Web服务器）。
    ```bash
    sudo systemctl stop nginx
    sudo certbot certonly --standalone -d example.com
    sudo systemctl start nginx
    ```
    *   `--standalone`：Certbot 会自己运行一个临时的Web服务器来完成验证 。
*   **Webroot 模式**：适用于服务器正在运行且不想中断服务的情况。
    ```bash
    sudo certbot certonly --webroot -w /var/www/html -d example.com
    ```
    *   `--webroot`：Certbot 会将验证文件放入指定的网站根目录（`-w`参数）让Let‘s Encrypt进行验证 。

#### 3. 通配符证书与DNS验证
通配符证书（如 `*.example.com`）可以保护一个域名的所有子域名。由于无法通过HTTP文件验证，**必须使用DNS验证**。
```bash
sudo certbot certonly --manual --preferred-challenges=dns -d "*.example.com" -d example.com
```
*   `--manual`：启用手动模式。
*   `--preferred-challenges=dns`：指定使用DNS挑战，命令运行后会提示你在域名DNS处添加一条特定的TXT记录以验证所有权 。此过程通常需要手动干预。对于支持API的DNS服务商（如阿里云、Cloudflare等），可以使用相应的Certbot DNS插件实现全自动化 。

#### 4. 证书的更新与管理
Let’s Encrypt 证书有效期为90天，因此定期更新至关重要。
*   **手动更新**：`sudo certbot renew` 
    *   此命令会检查 `/etc/letsencrypt/live/` 目录下所有距离过期不足30天的证书并进行更新。
*   **试运行（干跑）**：`sudo certbot renew --dry-run`
    *   在实际更新前进行完整测试，确保续订流程配置正确，强烈推荐定期执行 。
*   **强制更新**：`sudo certbot renew --force-renewal`
    *   即使证书未接近到期，也强制更新。通常用于测试或需要立即重新颁发证书的情况 。

#### 5. 查看与删除证书
*   **查看证书列表**：`sudo certbot certificates` 
    *   这会列出所有证书的名称、包含的域名和过期时间等信息。
*   **删除证书**：`sudo certbot delete --cert-name example.com` 
    *   根据提示或使用 `--cert-name` 参数指定要删除的证书。

### ⚙️ 实用高级参数
*   `-d DOMAIN`：指定域名，可多次使用以添加多个域名到一张证书中（SAN证书）。
*   `--test-cert`：从 Let‘s Encrypt 的**测试服务器**获取无效证书，避免在测试时触及生产环境的速率限制 。
*   `--agree-tos`：非交互式运行时，自动同意服务条款。
*   `-n, --non-interactive`：非交互式运行，适用于脚本操作。
*   `--pre-hook/--post-hook`：在证书更新**前/后**自动执行命令，例如关闭和重启Web服务器 。
    ```bash
    # 示例：更新证书后自动重载Nginx配置
    sudo certbot renew --post-hook "systemctl reload nginx"
    ```

### 💎 典型工作流程建议
对于大多数拥有Nginx或Apache服务器的用户，一个典型的工作流程是：
1.  **安装**：通过系统包管理器安装Certbot及其对应的Web服务器插件 。
2.  **获取证书**：使用 `sudo certbot --nginx`（或 `--apache`）命令，交互式地选择域名并完成安装。
3.  **测试续订**：运行 `sudo certbot renew --dry-run` 确保自动续订配置正确。
4.  **设置定时任务**：Certbot 通常会自动配置定时任务，但最好确认一下。你也可以手动添加，例如在crontab中添加 `0 3 * * * /usr/bin/certbot renew --quiet`，表示每天凌晨3点检查并续订证书 。