#!/bin/sh
# ============================================================================
#  install-kali.sh  -  one-click login-banner replacer for Kali / Debian / Ubuntu
# ----------------------------------------------------------------------------
#     sudo ./install-kali.sh              # install / replace (system-wide)
#     sudo ./install-kali.sh uninstall    # restore the original prompt
# ============================================================================
set -eu

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="/usr/local/bin/login-banner"
HOOK="/etc/profile.d/99-login-banner.sh"

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 运行：  sudo $0" >&2
    exit 1
fi

write_hook() {
    cat > "$HOOK" <<'EOF'
# /etc/profile.d/99-login-banner.sh
# System-wide login banner for all users (login shells only).
# Rendered by /usr/local/bin/login-banner.  Remove this file to disable.
case "$-" in
    *i*) ;;
    *) return 0 2>/dev/null || exit 0 ;;
esac
if [ -n "${LOGIN_BANNER_SHOWN:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
LOGIN_BANNER_SHOWN=1
export LOGIN_BANNER_SHOWN
if [ -x /usr/local/bin/login-banner ]; then
    SSH_BANNER_SHOW=always /usr/local/bin/login-banner
fi
EOF
    chmod 0644 "$HOOK"
    chown root:root "$HOOK" 2>/dev/null || true
}

if [ "${1:-install}" = "uninstall" ] || [ "${1:-install}" = "remove" ]; then
    rm -f "$TARGET" "$HOOK"
    if [ -f /etc/motd.banner-orig ]; then
        cp -a /etc/motd.banner-orig /etc/motd
        rm -f /etc/motd.banner-orig
    fi
    if [ -f /etc/update-motd.d/10-uname ]; then
        chmod +x /etc/update-motd.d/10-uname 2>/dev/null || true
        run-parts --lsbsysinit /etc/update-motd.d > /run/motd.dynamic 2>/dev/null || true
    fi
    echo ">> Kali: 已还原为原始登录提示。"
    exit 0
fi

echo ">> Kali / Debian / Ubuntu：安装登录横幅"

install -o root -g root -m 0755 "$REPO_DIR/bin/kali-login-banner" "$TARGET"
write_hook

# trim the noisy default MOTD
if [ -d /etc/update-motd.d ]; then
    [ -f /etc/motd.banner-orig ] || cp -a /etc/motd /etc/motd.banner-orig 2>/dev/null || true
    printf 'Kali GNU/Linux comes with ABSOLUTELY NO WARRANTY.\n' > /etc/motd
    [ -f /etc/update-motd.d/10-uname ] && chmod -x /etc/update-motd.d/10-uname 2>/dev/null || true
    run-parts --lsbsysinit /etc/update-motd.d > /run/motd.dynamic 2>/dev/null || true
fi

echo ">> 完成。"
echo "     $TARGET"
echo "     $HOOK"
echo "   下次登录（SSH / tty / su -）生效。只想 SSH 显示：把 hook 里的 always 改成 ssh"
echo "   卸载：  sudo $REPO_DIR/install-kali.sh uninstall"
