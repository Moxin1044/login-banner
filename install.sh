#!/bin/sh
# ============================================================================
#  install.sh - one-click installer / replacer for the fancy login banner
# ----------------------------------------------------------------------------
#  Auto-detects the distro and installs the matching banner for ALL users:
#     * Kali / Debian / Ubuntu  -> bin/kali-login-banner
#     * Arch Linux              -> bin/arch-login-banner
#
#  Usage:  sudo ./install.sh
# ============================================================================
set -eu

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$REPO_DIR/bin"
TARGET="/usr/local/bin/login-banner"
HOOK="/etc/profile.d/99-login-banner.sh"

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 运行：  sudo $0" >&2
    exit 1
fi

# ---- detect distro ---------------------------------------------------------
distro="kali"
if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-}${ID_LIKE:-}" in
        *arch*)                 distro="arch" ;;
        *kali*|*debian*|*ubuntu*) distro="kali" ;;
    esac
fi
src="$BIN_DIR/${distro}-login-banner"
[ -f "$src" ] || src="$BIN_DIR/kali-login-banner"

echo ">> 发行版: $distro   使用横幅: $(basename "$src")"

# ---- install the banner renderer ------------------------------------------
install -o root -g root -m 0755 "$src" "$TARGET"

# ---- install the system-wide login hook ------------------------------------
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

# ---- Debian/Kali: trim the noisy default MOTD ------------------------------
if [ -d /etc/update-motd.d ]; then
    [ -f /etc/motd.banner-orig ] || cp -a /etc/motd /etc/motd.banner-orig 2>/dev/null || true
    printf 'Kali GNU/Linux comes with ABSOLUTELY NO WARRANTY.\n' > /etc/motd
    if [ -f /etc/update-motd.d/10-uname ]; then
        chmod -x /etc/update-motd.d/10-uname 2>/dev/null || true
    fi
    run-parts --lsbsysinit /etc/update-motd.d > /run/motd.dynamic 2>/dev/null || true
fi

echo ">> 完成。安装位置:"
echo "     $TARGET"
echo "     $HOOK"
echo "   下次登录（SSH / tty / su -）即可看到新横幅。"
echo "   想只在 SSH 显示：把 $HOOK 里的 always 改成 ssh"
echo "   卸载：  sudo $REPO_DIR/uninstall.sh"
