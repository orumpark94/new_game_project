#!/usr/bin/env bash
# linux_init.sh.tpl: EC2 첫 부팅 시 호스트명을 지정하고 HTTP 데모 서비스를 등록합니다.
# main.tf에서 서버명을 주입하며, python3와 systemd가 설치된 AMI를 전제로 합니다.

set -euo pipefail
# OS 초기 설정 주입 방식만 보여주는 예제입니다. 비밀번호나 키를 포함하지 않습니다.
hostnamectl set-hostname "${hostname}"
install -d -m 0755 /opt/portfolio
printf '%s\n' 'Initialized by Terraform portfolio example' > /opt/portfolio/initialized.txt

# python3와 systemd가 설치된 AMI를 전제로 하며 패키지를 내려받지 않습니다.
command -v python3
install -d -m 0755 /opt/portfolio-web
printf '%s\n' 'Terraform portfolio demo' > /opt/portfolio-web/index.html
id portfolio-web >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin portfolio-web

cat > /etc/systemd/system/portfolio-web.service <<'UNIT'
[Unit]
Description=Terraform portfolio demo HTTP service
After=network.target

[Service]
Type=simple
User=portfolio-web
WorkingDirectory=/opt/portfolio-web
ExecStart=/usr/bin/env python3 -m http.server 8080 --bind 0.0.0.0
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now portfolio-web.service
