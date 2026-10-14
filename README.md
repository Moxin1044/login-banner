# login-banner

炫酷的 **SSH / 登录横幅**，一键替换系统默认登录提示。对**所有用户**生效，不影响 `scp` / `sftp` / `ssh host 命令`。

**一个脚本自动识别发行版** —— 按 `/etc/os-release` 选对应的 ASCII 图形、配色渐变和包管理器，不用再按系统挑脚本。

```
   _  __    _    _     ___     user@host
  | |/ /   / \  | |   |_ _|    OS      Kali GNU/Linux Rolling
  | ' /   / _ \ | |    | |     Kernel  6.19.14+kali-amd64
  | . \  / ___ \| |___ | |     Uptime  20 minutes
  |_|\_\/_/   \_\_____|___|    Shell   zsh
                               CPU     Intel Core i5-4590T
                               Updates  12 available (apt)
                               Memory  2.0G/3.8G  ██████░░░░░░ 52%
                               Disk    16G/94G  ██░░░░░░░░░░ 18%
```

```
      _    ____   ____ _   _     user@host
     / \  |  _ \ / ___| | | |    OS      Arch Linux
    / _ \ | |_) | |   | |_| |    Kernel  7.2.7-arch1-1
   / ___ \|  _ <| |___|  _  |    Uptime  1 week, 2 days
  /_/   \_\_| \_\\____|_| |_|    Shell   bash
                                 CPU     Intel Core i5-4590T
                                 Packages 1271 (pacman)
                                 Updates  511 available (pacman)
                                 Memory  2.3G/5.8G  █████░░░░░░░ 39%
                                 Disk    26G/98G  ███░░░░░░░░░ 28%
```

## 支持的发行版

脚本**不需要按系统选**，装上去它自己认。

| 家族 | 覆盖的发行版 | 包管理器 | 图形 |
| --- | --- | --- | --- |
| **Kali** | Kali Linux | apt | KALI（粉→紫→蓝→青） |
| **Debian** | Debian、Raspbian、Devuan、MX Linux | apt | DEBIAN（红） |
| **Ubuntu** | Ubuntu、Linux Mint、Pop!\_OS、Zorin、elementary、deepin | apt | UBUNTU（橙） |
| **Arch** | Arch Linux、EndeavourOS、Garuda、CachyOS | pacman | ARCH（蓝） |
| **Manjaro** | Manjaro | pacman | MANJARO（绿） |
| **Fedora** | Fedora、Nobara、Bazzite | dnf | FEDORA（深蓝） |
| **RHEL** | Red Hat Enterprise Linux | dnf / yum | RHEL（红） |
| **Rocky 系** | Rocky Linux、AlmaLinux、CentOS、Oracle Linux | dnf / yum | ROCKY（红） |
| **openSUSE** | openSUSE Leap / Tumbleweed、SLES | zypper | OPENSUSE（绿） |
| **Alpine** | Alpine Linux、postmarketOS | apk | ALPINE（青蓝） |
| **Gentoo** | Gentoo、Funtoo | portage | GENTOO（紫） |
| **Void** | Void Linux | xbps | VOID（绿） |
| **NixOS** | NixOS | nix | NIXOS（浅蓝） |
| **FreeBSD** | FreeBSD、DragonFly BSD | pkg | FREEBSD（红） |
| *兜底* | 其他任何系统 | **自动探测** | TUX 企鹅（灰） |

**包管理器探测是「遇到什么用什么」**：`apt` / `apt-get` / `dnf` / `yum` / `pacman` / `zypper` / `apk` / `xbps` / `emerge` / `nix-env` / `pkg` / `brew`。
认不出来就显示 `n/a`，**不会报错、不会卡住**（每个探测都带 `timeout`）。

## 一键安装 / 替换

```sh
git clone https://github.com/Moxin1044/login-banner.git
cd login-banner
sudo ./install.sh
```

脚本会自动：

- 把横幅装到 `/usr/local/bin/login-banner`
- 写 `/etc/profile.d/99-login-banner.sh`，所有用户登录时生效
- 顺手清掉系统自带那堆啰嗦的 MOTD（Debian 系处理 `/etc/update-motd.d`，RHEL 系处理 `/etc/motd.d`，**原文件备份为 `/etc/motd.login-banner-orig`**）

**先看看会做什么、会不会认错系统：**

```sh
./install.sh --check      # 不需要 root，只报检测结果 + 渲染一张预览
```

## 一键还原

```sh
sudo ./install.sh uninstall
```

会把 `/usr/local/bin/login-banner`、hook、以及旧的 `99-kali-banner.sh` 一并清掉，并把 MOTD 恢复回原样。

## 显示时机

默认**每次登录 shell**都显示（SSH 登录、tty 登录、`su -`）。
本地新开终端窗口、`scp`、`sftp`、`ssh host 命令` 都不受影响。

只想在 SSH 登录时显示：

```sh
sudo sed -i 's/SSH_BANNER_SHOW=always/SSH_BANNER_SHOW=ssh/' /etc/profile.d/99-login-banner.sh
```

单次控制：

```sh
SSH_BANNER_SHOW=never  login-banner    # 这一次不显示
SSH_BANNER_SHOW=ssh    login-banner    # 仅 SSH 时显示
```

## 预览与调试

```sh
# 不在登录场景里手动看（跳过 TTY 检测）
LOGIN_BANNER_FORCE=1 login-banner

# 预览别的发行版长什么样（只换图形/配色/OS 名，系统信息仍是本机真实值）
LOGIN_BANNER_FORCE=1 LOGIN_BANNER_SIMULATE=ubuntu login-banner
LOGIN_BANNER_FORCE=1 LOGIN_BANNER_SIMULATE=rocky  login-banner
```

`LOGIN_BANNER_SIMULATE` 取值：`kali` `debian` `ubuntu` `arch` `manjaro` `fedora` `rhel` `rocky` `suse` `alpine` `gentoo` `void` `nixos` `freebsd` `generic`

## 文件说明

| 路径 | 说明 |
| --- | --- |
| `bin/login-banner` | **唯一的横幅脚本**，自动识别发行版 |
| `install.sh` | 统一安装 / 还原 / `--check` |
| `bin/kali-login-banner`、`bin/arch-login-banner` | 兼容包装，转发到 `bin/login-banner` |
| `install-kali.sh`、`install-arch.sh` | 兼容包装，转发到 `install.sh` |

> 老版本是「一个系统一个脚本」，现在合并成一个。**旧的命令名和安装脚本都保留着**，指向新的实现，已有的安装和脚本不会断。

## 自定义

编辑 `bin/login-banner`：

- **改图形** —— 在 `BEGIN` 块里找对应发行版的分支，改 `logo[1..5]`（**5 行，宽度不必相同，会自动补空格对齐**）
- **改配色** —— 同分支下的 `rgb[1..5]`（24 位真彩）和 `x256[1..5]`（256 色降级），再加 `accent` / `accent256` / `tail` 控制标签色和主机名色
- **加新发行版** —— 在 `case "$_id"` 里加一行映射到某个 family，再到 awk 的 `BEGIN` 里加一个分支
- **改信息行** —— `info[1..n]`，加一行就把 `n_idx` 加一
- **改进度条** —— `makebar()` 里的长度与阈值配色

## 环境要求

- **POSIX `sh`**（不是 bash 专用，`dash` / `busybox sh` 都能跑）
- **`awk`** —— 渲染全靠它，任何 POSIX awk 均可
- 其余只用 `uname` / `df` / `uptime` / `date` / `hostname` 这些基础命令，**不依赖 GNU 专属选项**（BSD 上自动退回普通 `df` 写法）

## License

MIT
