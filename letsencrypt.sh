#!/bin/bash
DNS_DOMAIN_NAME="$1"
SSL_CERT_EMAIL="$2"
WEB_ROOT="/var/www/html"

echo ""
echo "=============================="
echo "Installing Python3 setting up virtual env and installing Certbot-nginx To Get SSL From Let's Encrypt"
echo "=============================="
echo ""
sudo apt-get -y install python3 python3-venv libaugeas0
sudo python3 -m venv /opt/certbot/
sudo /opt/certbot/bin/pip install --upgrade pip
sudo /opt/certbot/bin/pip install certbot certbot-nginx
sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot
echo ""
echo "=============================="
echo "Below Details are used to request for an SSL"
echo "Email : $SSL_CERT_EMAIL"
echo "Domain : $DNS_DOMAIN_NAME"
echo "=============================="
echo ""
sudo certbot  certonly --webroot -w "${WEB_ROOT}" --preferred-challenges http -m "$SSL_CERT_EMAIL" -d "$DNS_DOMAIN_NAME" -n --agree-tos --no-eff-email --preferred-chain="ISRG Root X1"
