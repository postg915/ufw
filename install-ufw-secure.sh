#!/bin/bash
set -e

echo "[+] Updating system"
apt update -y

echo "[+] Installing UFW"
apt install -y ufw

echo "[+] Setting default firewall policy"
ufw default deny incoming
ufw default allow outgoing

echo "[+] Allowing HTTP/HTTPS"
ufw allow 80/tcp
ufw allow 443/tcp

echo "[+] Allowing OpenVPN"
ufw allow 1194/udp

echo "[+] Removing plain SSH allow rule if exists"
ufw delete allow 22/tcp 2>/dev/null || true
ufw delete allow OpenSSH 2>/dev/null || true

echo "[+] Enabling SSH rate limiting"
ufw limit 22/tcp

echo "[+] Enabling OpenVPN rate limiting"
ufw limit 1194/udp

echo "[+] Disabling IPv6 in UFW"
sed -i 's/^IPV6=.*/IPV6=no/' /etc/ufw/ufw.conf

echo "[+] Enabling UFW"
ufw --force enable

echo "[+] Reloading UFW"
ufw reload

echo "[+] Final firewall status:"
ufw status verbose

echo "[✔] UFW secure configuration completed"
