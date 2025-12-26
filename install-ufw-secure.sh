#!/bin/bash
set -e

echo "[+] Updating system"
apt update -y

echo "[+] Installing UFW"
apt install -y ufw

echo "[+] Disabling IPv6 at kernel level"
cat <<EOF >/etc/sysctl.d/99-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

sysctl --system

echo "[+] Disabling IPv6 in UFW config"
sed -i 's/^IPV6=.*/IPV6=no/' /etc/ufw/ufw.conf

echo "[+] Resetting UFW (removing old IPv4/IPv6 rules)"
ufw --force reset

echo "[+] Setting default firewall policy"
ufw default deny incoming
ufw default allow outgoing

echo "[+] Allowing HTTP/HTTPS"
ufw allow 80/tcp
ufw allow 443/tcp

echo "[+] Enabling SSH rate limiting"
ufw limit 22/tcp

echo "[+] Enabling OpenVPN rate limiting"
ufw limit 1194/udp

echo "[+] Enabling UFW"
ufw --force enable

echo "[+] Reloading UFW"
ufw reload

echo "[+] Final firewall status:"
ufw status verbose

echo "[+] IPv6 address check:"
ip a | grep inet6 || echo "IPv6 disabled"

echo "[✔] UFW IPv4-only secure configuration completed"
