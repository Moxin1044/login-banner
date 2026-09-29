#!/bin/sh
# ============================================================================
#  uninstall.sh - restore the original login prompt
#  Usage:  sudo ./uninstall.sh
# ============================================================================
set -eu

TARGET="/usr/local/bin/login-banner"
HOOK="/etc/profile.d/99-login-banner.sh"

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 运行：  sudo $0" >&2
    exit 1
fi

rm -f "$TARGET" "$HOOK"

# ---- Debian/Kali: restore the original MOTD --------------------------------
if [ -f /etc/motd.banner-orig ]; then
    cp -a /etc/motd.banner-orig /etc/motd
    rm -f /etc/motd.banner-orig
fi
if [ -f /etc/update-motd.d/10-uname ]; then
    chmod +x /etc/update-motd.d/10-uname 2>/dev/null || true
    run-parts --lsbsysinit /etc/update-motd.d > /run/motd.dynamic 2>/dev/null || true
fi

echo ">> 已卸载，登录提示恢复到原始状态。"
