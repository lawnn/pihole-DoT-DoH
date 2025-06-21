#!/bin/bash

# 使用方法: sudo bash setup_dnsproxy.sh <your.domain.name>

#===============================
# 設定
#===============================

DNS_DOMAIN_NAME="$1"
if [ -z "$DNS_DOMAIN_NAME" ]; then
  echo "Usage: $0 <your-domain-name>"
  exit 1
fi

# アーキテクチャ判定
ARCH=$(uname -m)
ARCH=${ARCH/x86_64/amd64}
ARCH=${ARCH/aarch64/arm64}

# dnsproxy の最新バージョン取得
DNSPROXY_VER=$(curl -s https://api.github.com/repos/AdguardTeam/dnsproxy/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

echo "📦 Downloading dnsproxy v$DNSPROXY_VER for $ARCH"

# ダウンロードと展開
echo "📂 Creating temporary directory for dnsproxy..."
TMP_DIR="/tmp/dnsproxy"
mkdir -p "$TMP_DIR"
wget -qO "$TMP_DIR/dnsproxy.tar.gz" "https://github.com/AdguardTeam/dnsproxy/releases/download/v$DNSPROXY_VER/dnsproxy-linux-$ARCH-v$DNSPROXY_VER.tar.gz"
tar -xzf "$TMP_DIR/dnsproxy.tar.gz" -C "$TMP_DIR"
sudo mv "$TMP_DIR/linux-$ARCH/dnsproxy" /usr/local/bin/
sudo rm -rf "$TMP_DIR"
sudo chmod +x /usr/local/bin/dnsproxy
if [ ! -f /usr/local/bin/dnsproxy ]; then
  echo "🛑 dnsproxy installation failed. Please check the logs."
  exit 1
fi
echo "✅ dnsproxy v$DNSPROXY_VER installed successfully."
#===============================

# dnsproxy用ディレクトリ作成
echo "📂 Creating directory for dnsproxy..."
sudo mkdir -p /opt/dnsproxy

# 起動スクリプト作成
echo "📝 Creating start script for dnsproxy..."
sudo tee /opt/dnsproxy/start.sh > /dev/null <<EOF
#!/bin/bash
HOSTNAME="$DNS_DOMAIN_NAME"

CERTSPATH=/etc/letsencrypt/live/\$HOSTNAME
CERT=\$CERTSPATH/fullchain.pem
PKEY=\$CERTSPATH/privkey.pem

DNSPROXY_OPTS="--https-port=443 --tls-port=853 --tls-crt=\$CERT --tls-key=\$PKEY -u 127.0.0.1:53 -p 0"

/usr/local/bin/dnsproxy \$DNSPROXY_OPTS
EOF

sudo chmod a+x /opt/dnsproxy/start.sh

# systemd サービス作成
echo "📄 Creating systemd service for dnsproxy..."
sudo touch /lib/systemd/system/dnsproxy.service
sudo echo "[Unit]
Description=AdguardTeam/dnsproxy service
After=syslog.target network-online.target

[Service]
Type=simple
User=root
ExecStart=/opt/dnsproxy/start.sh
ExecStop=/usr/bin/pkill dnsproxy
Restart=on-failure
RestartSec=10
KillMode=process

[Install]
WantedBy=multi-user.target" > /lib/systemd/system/dnsproxy.service

# systemd有効化と起動
echo "🔄 Enabling and starting dnsproxy service..."
# sudo systemctl daemon-reexec
# sudo systemctl daemon-reload
sudo systemctl enable dnsproxy
sudo systemctl restart dnsproxy
sudo systemctl status dnsproxy --no-pager

# DNS over TLS (DoT) と DNS over HTTPS (DoH) の設定
sudo apt install knot-dnsutils openssl

# 動作確認 DoT
echo "🔍 Checking DNS over TLS (DoT) and DNS over HTTPS (DoH) setup..."
kdig -d @$DNS_DOMAIN_NAME +tls-ca google.com
openssl s_client -showcerts -servername $DNS_DOMAIN_NAME -connect $DNS_DOMAIN_NAME:853

# 動作確認 DoH
echo "🔍 Checking DNS over HTTPS (DoH) setup..."
kdig -d @$DNS_DOMAIN_NAME +https google.com
openssl s_client -showcerts -servername $DNS_DOMAIN_NAME -connect $DNS_DOMAIN_NAME:443
