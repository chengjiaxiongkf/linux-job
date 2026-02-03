from flask import Flask, request, jsonify
import smtplib
from email.mime.text import MIMEText
from email.header import Header
from email.utils import formataddr
from datetime import date
from collections import defaultdict

app = Flask(__name__)

# IP请求记录 {ip: {date: count}}
ip_request_log = defaultdict(lambda: defaultdict(int))

@app.route('/submit_contact', methods=['POST'])
def send_mail():
    # ========== 配置变量 ==========
    ENABLE_IP_LIMIT = True             # 是否启用IP限制（设为False可关闭限制）
    MAX_REQUESTS_PER_DAY = 5           # 每个IP每天最大请求次数
    SMTP_HOST = 'smtp.qq.com'          # SMTP服务器地址
    SMTP_PORT = 465                    # SMTP端口
    SMTP_USER = '514471552@qq.com'     # 发件邮箱
    SMTP_PASSWORD = 'xx' # 邮箱授权码
    MAIL_NAME = 'LUXWEAVE|奢织'                       # 显示名称
    # ==============================

    try:
        # >>>>>>>>>> IP请求频率限制 开始 >>>>>>>>>>
        # 如需关闭限制，将上方 ENABLE_IP_LIMIT 设为 False
        if ENABLE_IP_LIMIT:
            client_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
            if client_ip:
                client_ip = client_ip.split(',')[0].strip()
            today = date.today().isoformat()
            ip_request_log[client_ip][today] += 1
            if ip_request_log[client_ip][today] > MAX_REQUESTS_PER_DAY:
                return jsonify({'success': False, 'message': '今日请求次数已达上限，请明天再试'}), 429
        # <<<<<<<<<< IP请求频率限制 结束 <<<<<<<<<<

        # 获取表单数据
        data = request.get_json() if request.is_json else request.form
        name = data.get('name', '未知')
        email = data.get('email', '')
        company = data.get('company', '未知')
        message = data.get('message', '未知')

        # 校验email必填
        if not email or not email.strip():
            return jsonify({'success': False, 'message': '邮箱地址不能为空'}), 400

        email = email.strip()

        # 发送邮件
        content = f"姓名: {name}\n邮箱: {email}\n公司: {company}\n留言: {message}"
        msg = MIMEText(content, 'plain', 'utf-8')
        msg['Subject'] = Header(f"官网新留言: {name}", 'utf-8')
        msg['From'] = formataddr((str(Header(MAIL_NAME, 'utf-8')), SMTP_USER))
        msg['To'] = formataddr((str(Header(MAIL_NAME, 'utf-8')), email))

        with smtplib.SMTP_SSL(SMTP_HOST, SMTP_PORT) as server:
            server.login(SMTP_USER, SMTP_PASSWORD)
            server.send_message(msg)

        return jsonify({'success': True, 'message': '感谢您的留言！我们会尽快与您联系。'}), 200

    except Exception as e:
        import traceback
        print(traceback.format_exc()) # 这行会将具体的报错行数和原因打印到 docker logs
        return jsonify({'success': False, 'message': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
