#!/bin/sh
# @Moxin1044 2026-10-15
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Moxin1044
# ============================================================================
#  install.sh  -  one-click login-banner installer
# ----------------------------------------------------------------------------
#     sudo ./install.sh              # install / replace (system-wide)
#     sudo ./install.sh uninstall    # restore the original login prompt
#
#  Auto-detects the distribution.  The banner itself detects the OS at run
#  time, so the same installer works on every supported platform.
# ============================================================================
set -eu

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="/usr/local/bin/login-banner"
HOOK="/etc/profile.d/99-login-banner.sh"
MOTD_ORIG="/etc/motd.login-banner-orig"

# ---- --check: report detection without touching anything -------------------
CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

if [ "$(id -u)" -ne 0 ] && [ "$CHECK_ONLY" -ne 1 ]; then
    echo "请用 root 运行：  sudo $0" >&2
    exit 1
fi

# ---- distribution family (same rules as the banner) ------------------------
fam="generic"
if [ -r /etc/os-release ]; then
    _id="$(. /etc/os-release 2>/dev/null; printf '%s' "${ID:-}")"
    _like="$(. /etc/os-release 2>/dev/null; printf '%s' "${ID_LIKE:-}")"
    _pretty="$(. /etc/os-release 2>/dev/null; printf '%s' "${PRETTY_NAME:-${NAME:-}}")"
else
    _id=""; _like=""; _pretty=""
fi
case "$_id" in
    kali)                                        fam="kali" ;;
    debian|raspbian|devuan|mx|antix|ubuntu|linuxmint|pop|elementary|zorin|neon|deepin)
                                                 fam="debian" ;;
    arch|artix|manjaro|endeavouros|garuda|cachyos|rebornos)
                                                 fam="arch" ;;
    fedora|nobara|bazzite)                       fam="fedora" ;;
    rhel|centos|rocky|almalinux|ol|scientific|virtuozzo)
                                                 fam="rhel" ;;
    opensuse*|sles|sled|suse)                    fam="suse" ;;
    alpine|postmarketos)                         fam="alpine" ;;
    gentoo|funtoo)                               fam="gentoo" ;;
    void)                                        fam="void" ;;
    nixos)                                       fam="nixos" ;;
    freebsd|dragonfly)                           fam="freebsd" ;;
    *)
        case " $_like " in
            *debian*|*ubuntu*) fam="debian" ;;
            *arch*)            fam="arch"   ;;
            *fedora*)          fam="fedora" ;;
            *rhel*)            fam="rhel"   ;;
            *suse*)            fam="suse"   ;;
            *alpine*)          fam="alpine" ;;
            *)                 fam="generic";;
        esac ;;
esac

# ---- the login hook (shared by every platform) -----------------------------
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

# ---- trim the noisy default MOTD -------------------------------------------
trim_motd() {
    # Debian / Ubuntu / Kali: /etc/update-motd.d + /run/motd.dynamic
    if [ -d /etc/update-motd.d ]; then
        [ -f "$MOTD_ORIG" ] || cp -a /etc/motd "$MOTD_ORIG" 2>/dev/null || true
        printf 'This system is managed. Unauthorised access is prohibited.\n' > /etc/motd
        [ -f /etc/update-motd.d/10-uname ] && chmod -x /etc/update-motd.d/10-uname 2>/dev/null || true
        run-parts --lsbsysinit /etc/update-motd.d > /run/motd.dynamic 2>/dev/null || true
        return 0
    fi
    # RHEL / Fedora: /etc/motd.d
    if [ -d /etc/motd.d ]; then
        [ -f "$MOTD_ORIG" ] || cp -a /etc/motd "$MOTD_ORIG" 2>/dev/null || true
        printf 'This system is managed. Unauthorised access is prohibited.\n' > /etc/motd
        return 0
    fi
    # others: only touch /etc/motd if it currently holds the stock text
    if [ -f /etc/motd ]; then
        case "$(head -c 200 /etc/motd 2>/dev/null)" in
            *"have a lot of fun"*|*"comes with ABSOLUTELY NO WARRANTY"*|*"Arch Linux"*)
                [ -f "$MOTD_ORIG" ] || cp -a /etc/motd "$MOTD_ORIG" 2>/dev/null || true
                : > /etc/motd
                ;;
        esac
    fi
    return 0
}

restore_motd() {
    if [ -f "$MOTD_ORIG" ]; then
        cp -a "$MOTD_ORIG" /etc/motd 2>/dev/null || true
        rm -f "$MOTD_ORIG"
    fi
    if [ -d /etc/update-motd.d ] && [ -f /etc/update-motd.d/10-uname ]; then
        chmod +x /etc/update-motd.d/10-uname 2>/dev/null || true
        run-parts --lsbsysinit /etc/update-motd.d > /run/motd.dynamic 2>/dev/null || true
    fi
}

# ---- --check ---------------------------------------------------------------
if [ "$CHECK_ONLY" -eq 1 ]; then
    echo "仓库目录  : $REPO_DIR"
    echo "发行版 ID : ${_id:-（无 /etc/os-release）}"
    echo "ID_LIKE   : ${_like:-—}"
    echo "显示名称  : ${_pretty:-—}"
    echo "识别家族  : $fam"
    echo "  安装目标: $TARGET"
    echo "  hook    : $HOOK"
    [ -d /etc/update-motd.d ] && echo "  motd    : /etc/update-motd.d（Debian 系）"
    [ -d /etc/motd.d ]       && echo "  motd    : /etc/motd.d（RHEL 系）"
    echo
    echo "横幅实测预览（强制渲染）:"
    LOGIN_BANNER_FORCE=1 "$REPO_DIR/bin/login-banner"
    exit 0
fi

# ---- uninstall -------------------------------------------------------------
if [ "${1:-install}" = "uninstall" ] || [ "${1:-install}" = "remove" ]; then
    rm -f "$TARGET" "$HOOK"
    rm -f /usr/local/bin/kali-login-banner /usr/local/bin/arch-login-banner
    rm -f /etc/profile.d/99-kali-banner.sh          # legacy hook name
    restore_motd
    echo ">> 已还原为原始登录提示。"
    exit 0
fi

# ---- install ---------------------------------------------------------------
echo ">> 安装登录横幅（检测到：${_pretty:-$_id} / 家族：$fam）"

install -o root -g root -m 0755 "$REPO_DIR/bin/login-banner" "$TARGET"

# keep the old per-OS command names working
ln -sf login-banner /usr/local/bin/kali-login-banner
ln -sf login-banner /usr/local/bin/arch-login-banner

write_hook
trim_motd

echo ">> 完成。"
echo "     $TARGET"
echo "     $HOOK"
echo "   下次登录（SSH / tty / su -）生效。"
echo "   只想 SSH 显示：  把 hook 里的 SSH_BANNER_SHOW=always 改成 ssh"
echo "   预览：            LOGIN_BANNER_FORCE=1 $TARGET"
echo "   预览别的发行版：  LOGIN_BANNER_FORCE=1 LOGIN_BANNER_SIMULATE=ubuntu $TARGET"
echo "   卸载：            sudo $REPO_DIR/install.sh uninstall"
