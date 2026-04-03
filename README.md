# Debian Chroot Manager

在 Android 设备上通过 chroot 运行 Debian Bookworm 的管理脚本。

## 适用情况

- ✅ 有 Root 权限的 Android 设备（APatch/KernelSU/Magisk）
- ✅ 需要完整的 Linux 环境（编译、运行服务）
- ✅ 需要 SSH 远程访问 Android 设备
- ✅ 在 Termux 之外运行 Linux 服务

## 不适用情况

- ❌ 没有 Root 权限的设备
- ❌ 存储空间非常有限的设备

## 具体用途

1. **SSH 服务器** - 通过 22 端口远程访问 Android
2. **编译环境** - gcc, make, python3, build-essential
3. **Web 服务器** - nginx, apache, python flask/django
4. **Git 服务器** - 私有代码仓库
5. **Python 环境** - 数据分析、机器学习
6. **数据库** - MySQL, PostgreSQL

## 安装

### 1. 安装 chroot-distro 模块

在 APatch/Magisk/KernelSU 中安装 [chroot-distro](https://github.com/Magisk-Modules-Alt-Repo/chroot-distro) 模块。

### 2. 下载并安装 Debian

```bash
chroot-distro download debian
chroot-distro install debian
```

### 3. 上传管理脚本

将 `1.sh` 上传到手机 `/data/local/tmp/` 目录：

```bash
adb push 1.sh /data/local/tmp/1.sh
chmod 755 /data/local/tmp/1.sh
```

## 使用方法

```bash
# 登录 Debian
/data/local/tmp/1.sh login

# 启动 SSH
/data/local/tmp/1.sh start-ssh

# 停止 SSH
/data/local/tmp/1.sh stop-ssh

# 安装软件
/data/local/tmp/1.sh install python3-pip

# 查看状态
/data/local/tmp/1.sh status
```

## SSH 连接

- **地址**: 127.0.0.1 或局域网 IP
- **端口**: 22
- **用户名**: root
- **密码**: 123456

## 已知问题

1. `/dev/null` 权限问题 - 脚本会自动修复
2. systemd 在 chroot 中不完全支持
3. 部分网络服务需要额外配置

## 目录结构

```
/data/local/chroot-distro/debian-bookworm-aarch64/  # Debian 根目录
/data/local/tmp/1.sh                                   # 管理脚本
```

## 技术说明

- **实现方式**: chroot（不是 proot）
- **Debian 版本**: Bookworm (aarch64)
- **Root 方案**: APatch/KernelSU/Magisk

## 许可证

MIT License
