# login-banner

炫酷的 **SSH / 登录横幅**，一条命令替换系统默认登录提示。支持 **Kali/Debian** 与 **Arch Linux**，对**所有用户**生效，不影响 `scp` / `sftp` / `ssh host 命令`。

```
   _  __    _    _     ___     user@host
  | |/ /   / \  | |   |_ _|    OS      Kali GNU/Linux Rolling
  | ' /   / _ \ | |    | |     Kernel  6.19.14+kali-amd64
  | . \  / ___ \| |___ | |     Uptime  20 minutes
  |_|\_\/_/   \_\_____|___|    Shell   zsh
                               CPU     Intel Core i5-4590T
                               Memory  2.0G/3.8G  ██████░░░░░░ 52%
                               Disk    16G/94G  ██░░░░░░░░░░ 18%
```

Arch Linux 上会显示蓝色的 `ARCH` 以及 `Packages (pacman)` 计数：

```
      _    ____   ____ _   _     user@host
     / \  |  _ \ / ___| | | |    OS      Arch Linux
    / _ \ | |_) | |   | |_| |    Kernel  linux
   / ___ \|  _ <| |___|  _  |    Packages 1234 (pacman)
  /_/   \_\_| \_\\____|_| |_|    ...
```

## 一键安装 / 替换

```sh
git clone <本仓库地址> login-banner && cd login-banner
sudo ./install.sh
```

脚本会自动识别当前发行版（Kali/Debian 或 Arch），安装对应横幅到
`/usr/local/bin/login-banner`，并写入 `/etc/profile.d/99-login-banner.sh`（所有用户登录时生效）。

## 一键卸载 / 还原

```sh
sudo ./uninstall.sh
```

## 显示时机

默认**每次登录 shell**都显示（SSH 登录、tty 登录、`su -`）。
本地新开终端窗口、`scp`、`sftp`、`ssh host 命令` 都不受影响。

只想在 SSH 登录时显示：

```sh
sudo sed -i 's/SSH_BANNER_SHOW=always/SSH_BANNER_SHOW=ssh/' /etc/profile.d/99-login-banner.sh
```

手动预览：

```sh
login-banner                       # 立即查看
SSH_BANNER_SHOW=never login-banner # 强制不显示
```

## 文件说明

| 路径 | 说明 |
| --- | --- |
| `bin/kali-login-banner` | Kali/Debian 横幅（粉→紫→蓝→青渐变 `KALI`） |
| `bin/arch-login-banner` | Arch 横幅（蓝色渐变 `ARCH` + pacman 包数） |
| `install.sh` | 一键安装/替换（自动识别发行版） |
| `uninstall.sh` | 一键卸载/还原 |

## 自定义

编辑 `bin/*-login-banner`：

- `logo[1..5]` —— ASCII 图形
- `rgb[]` / `x256[]` —— 逐行渐变色
- `info[]` —— 右侧信息面板
- `makebar()` —— 进度条长度与阈值配色

## License

MIT
