# 🛡️ Pi-hole + DoT & DoH 構築ガイド

> Web3 時代に向けて、**自宅DNSをセキュアに進化**。  
> `dnsproxy`, `Let's Encrypt`, `Unbound`, `Pi-hole/AdGuard Home` を組み合わせて  
> **DoT / DoH 対応の広告ブロックDNSサーバ**を構築します。

---

## 🔍 概要

このリポジトリは、安全で広告のないインターネット環境を提供するためのスクリプトとガイドを提供します：

- ✅ **DoH/DoT 対応 DNS（外部からのセキュア接続）**
- ✅ **広告フィルタリング（Pi-hole または AdGuard Home）**
- ✅ **ローカル再帰リゾルバ（Unbound）**
- ✅ **TLS証明書の自動取得（Let's Encrypt）**

---

## 🛠️ 必要な準備

1. **ポートの開放**（HGW/VPS/クラウド共通）  
   - `443/tcp`（DoH）  
   - `853/tcp`（DoT）  

2. **DNSフィルターの準備**  
   - Pi-hole または AdGuard Home のインストール（※本リポジトリ外）

---

## 📥 スクリプトの導入・実行

1. **スクリプトをダウンロード**

```bash
# Unbound インストール用
wget https://raw.githubusercontent.com/lawnn/pihole-DoT-DoH/refs/heads/main/install-unbound.sh

# Let's Encrypt 証明書取得用
wget https://raw.githubusercontent.com/lawnn/pihole-DoT-DoH/refs/heads/main/letsencrypt.sh

# dnsproxy セットアップ用
wget https://raw.githubusercontent.com/lawnn/pihole-DoT-DoH/refs/heads/main/setup-dnsproxy.sh
```
各スクリプトを順番に実行
```bash
# Unbound をインストール（ローカルDNSリゾルバ）
sudo bash install-unbound.sh

# Let's Encrypt で TLS 証明書を取得（ドメインとメールを指定）
sudo bash letsencrypt.sh your.domain.name your@email.com

# dnsproxy をセットアップ（DoH/DoT 対応プロキシを構築）
sudo bash setup-dnsproxy.sh your.domain.name
```
## ⚙️ クライアント設定方法
Android スマートフォン（DoT）
```
設定 > ネットワークとインターネット > プライベートDNS
→ プロバイダのホスト名: your.domain.name
```
```
Chrome / Brave / Firefox（DoH）
ブラウザ設定 → プライバシーとセキュリティ → セキュアDNS
カスタムDNSプロバイダとして以下を指定：

https://your.domain.name/dns-query
```
✅ 動作確認コマンド
DoT（DNS over TLS）

## DoT の名前解決確認
`kdig -d @your.domain.name +tls-ca google.com`
## TLS 通信ができているか確認
`openssl s_client -connect your.domain.name:853 -servername your.domain.name`

## DoH（DNS over HTTPS） DoH による名前解決
```bash
kdig -d @your.domain.name +https google.com
```
```bash
openssl s_client -connect your.domain.name:443 -servername your.domain.name
```
## ✅ 動作中の確認（systemd）
```bash
sudo systemctl status dnsproxy
```
### 出力例（正常動作中）:

```bash
● dnsproxy.service - AdguardTeam/dnsproxy service
     Active: active (running) ...
     ExecStart=/opt/dnsproxy/start.sh
```
## 📦 推奨環境
|項目	|推奨
|------|------|
|OS              |Raspberry Pi OS / Ubuntu / Debian|
|DNS フィルター   |Pi-hole / AdGuard Home|
|TLS 証明書       |Let's Encrypt (certbot)|
|接続             |IPv4/IPv6 両対応を推奨|
---

## 📄 ライセンス
このリポジトリは MIT License の下で公開されています。

## 🙋 貢献・フィードバック
Issue や Pull Request 大歓迎！

改善提案・不具合報告・機能要望などお気軽にご連絡ください。

# Sources
- https://github.com/jakenology/Tutorials/blob/master/Pi-hole/dnsproxy.md
- https://github.com/AdguardTeam/dnsproxy








