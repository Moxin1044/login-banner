# login-banner

炫酷的 **SSH / 登录横幅**，一键替换系统默认登录提示。对**所有用户**生效，不影响 `scp` / `sftp` / `ssh host 命令`。

- **Kali / Debian / Ubuntu** —— 粉→紫→蓝→青渐变的 `KALI`
- **Arch Linux** —— 蓝色渐变的 `ARCH` + pacman 包数

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

```
      _    ____   ____ _   _     user@host
     / \  |  _ \ / ___| | | |    OS      Arch Linux
    / _ \ | |_) | |   | |_| |    Kernel  7.2.7-arch1-1
   / ___ \|  _ <| |___|  _  |    Packages 1270 (pacman)
  /_/   \_\_| \_\\____|_| |_|    ...
```

## 一键安装 / 替换

按系统选一个脚本，`sudo` 运行即可（会自动安装到 `/usr/local/bin/login-banner`，
并写入 `/etc/profile.d/99-login-banner.sh`，所有用户登录时生效）。

```sh
git clone git@github.com:Moxin1044/login-banner.git
cd login-banner

# Kali / Debian / Ubuntu
sudo ./install-kali.sh

# Arch Linux
sudo ./install-arch.sh
```

## 一键还原

```sh
sudo ./install-kali.sh uninstall      # 或 install-arch.sh uninstall
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
| `bin/kali-login-banner` | Kali/Debian 横幅 |
| `bin/arch-login-banner` | Arch 横幅 |
| `install-kali.sh` | Kali/Debian 一键安装/还原 |
| `install-arch.sh` | Arch 一键安装/还原 |

## 自定义

编辑 `bin/*-login-banner`：

- `logo[1..5]` —— ASCII 图形
- `rgb[]` / `x256[]` —— 逐行渐变色
- `info[]` —— 右侧信息面板
- `makebar()` —— 进度条长度与阈值配色

## License

MIT
