#!/bin/bash
# delete nginx.conf
sudo rm /etc/nginx/nginx.conf

# ========= 📁 dot-and-doh-to-dns.confの編集 ========== #
NGINX_CONF="/etc/nginx/nginx.conf"
NGINX_SCRIPT_URL="https://raw.xxxxxxxxxxxx"

sudo wget -qO "$NGINX_CONF" "$NGINX_SCRIPT_URL"

# replace {dns_server} and {dns_domain_name} in dot-and-doh-to-dns.conf
echo "Editing nginx.conf"
sudo wget -qO "$NJS_DEST" "$NJS_SCRIPT_URL"
sudo sed -i 's/{dns_domain_name}/'$DNS_DOMAIN_NAME'/g' /etc/nginx/nginx.conf

# ========== 📁 dhparam.pem存在チェック ========== #
if [ ! -f /etc/nginx/dhparam.pem ]; then
  echo "🔐 dhparam.pem が存在しないため作成中（数分かかる可能性あり）..."
  sudo openssl dhparam -out /etc/nginx/dhparam.pem 2048
fi

# ========== 📁 モジュール存在チェック ========== #
# 確認: ngx_http_js_module が有効か
if ! nginx -V 2>&1 | grep -q ngx_http_js_module; then
  echo "🛑 nginx の ngx_http_js_module が有効ではありません。再ビルドまたは公式njs対応パッケージのインストールが必要です。"
fi

if ! [ -f /usr/lib/nginx/modules/ngx_stream_js_module.so ]; then
    echo "📦 ngx_stream_js_module.so が見つかりません。nginx-module-njs をインストール中..."
    sudo apt install -y nginx nginx-module-njs
fi

# 再確認（念のため）
if ! [ -f /usr/lib/nginx/modules/ngx_stream_js_module.so ]; then
    echo "🛑 ngx_stream_js_module.so がインストールされていません。手動で nginx をパージ後 nginx を公式の手順でインストールしてください"
    exit 1
fi