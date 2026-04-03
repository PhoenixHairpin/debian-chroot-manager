#!/system/bin/sh
#==========================================
# Debian Chroot 管理脚本
# 适用设备：Android (APatch/KernelSU/Magisk)
# Debian 版本：bookworm (aarch64)
#==========================================

DEBIAN_DIR="/data/local/chroot-distro/debian-bookworm-aarch64"
SSH_PORT=22

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否以 root 运行
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "${RED}请使用 root 权限运行此脚本！${NC}"
        exit 1
    fi
}

# 挂载必要的文件系统
mount_debian() {
    mount -t proc /proc "$DEBIAN_DIR/proc" 2>/dev/null
    mount -t sysfs /sys "$DEBIAN_DIR/sys" 2>/dev/null
    mount -t devpts devpts "$DEBIAN_DIR/dev/pts" 2>/dev/null
    mount -t tmpfs tmpfs "$DEBIAN_DIR/run" 2>/dev/null
}

# 卸载文件系统
umount_debian() {
    umount "$DEBIAN_DIR/proc" 2>/dev/null
    umount "$DEBIAN_DIR/sys" 2>/dev/null
    umount "$DEBIAN_DIR/dev/pts" 2>/dev/null
    umount "$DEBIAN_DIR/run" 2>/dev/null
}

# 修复 /dev/null
fix_dev_null() {
    if [ -f "$DEBIAN_DIR/dev/null" ]; then
        rm -f "$DEBIAN_DIR/dev/null"
    fi
    mknod -m 666 "$DEBIAN_DIR/dev/null" c 1 3 2>/dev/null
}

# 登录 Debian
login() {
    check_root
    fix_dev_null
    mount_debian
    echo "${GREEN}进入 Debian...${NC}"
    chroot "$DEBIAN_DIR" /bin/su - root
}

# 启动 SSH
start_ssh() {
    check_root
    fix_dev_null
    mount_debian
    
    # 配置 SSH（如果不存在）
    if [ ! -f "$DEBIAN_DIR/etc/ssh/sshd_config" ]; then
        mkdir -p "$DEBIAN_DIR/etc/ssh"
        cat > "$DEBIAN_DIR/etc/ssh/sshd_config" << 'EOF'
Port 22
PermitRootLogin yes
PasswordAuthentication yes
EOF
    fi
    
    # 启动 sshd
    chroot "$DEBIAN_DIR" /bin/sh -c "echo 'root:123456' | chpasswd && /usr/sbin/sshd" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "${GREEN}SSH 已启动！${NC}"
        echo "连接信息："
        echo "  地址: 127.0.0.1"
        echo "  端口: $SSH_PORT"
        echo "  用户名: root"
        echo "  密码: 123456"
    else
        echo "${RED}SSH 启动失败${NC}"
    fi
}

# 停止 SSH
stop_ssh() {
    check_root
    chroot "$DEBIAN_DIR" /bin/sh -c "pkill sshd" 2>/dev/null
    echo "${GREEN}SSH 已停止${NC}"
}

# 安装软件
install_pkg() {
    if [ -z "$2" ]; then
        echo "用法: $0 install <软件包名>"
        return
    fi
    check_root
    fix_dev_null
    mount_debian
    chroot "$DEBIAN_DIR" /bin/sh -c "apt-get update && apt-get install -y $2"
}

# 显示状态
status() {
    echo "=== Debian Chroot 状态 ==="
    echo ""
    
    # 检查目录
    if [ -d "$DEBIAN_DIR" ]; then
        echo "${GREEN}✓ Debian 已安装${NC}"
    else
        echo "${RED}✗ Debian 未安装${NC}"
        return
    fi
    
    # 检查 SSH
    if pgrep -f "sshd" > /dev/null; then
        echo "${GREEN}✓ SSH 正在运行${NC}"
    else
        echo "${YELLOW}○ SSH 未运行${NC}"
    fi
    
    # 显示 IP
    echo ""
    echo "=== 网络信息 ==="
    ip addr show wlan0 2>/dev/null | grep inet | awk '{print "WiFi IP: " $2}' || echo "WiFi: 未连接"
    ip addr show rmnet_data0 2>/dev/null | grep inet | awk '{print "移动网络 IP: " $2}' || true
    echo "localhost: 127.0.0.1"
}

# 显示帮助
help() {
    echo "=== Debian Chroot 管理脚本 ==="
    echo ""
    echo "用法: $0 <命令>"
    echo ""
    echo "命令:"
    echo "  login         登录 Debian"
    echo "  start-ssh     启动 SSH 服务"
    echo "  stop-ssh      停止 SSH 服务"
    echo "  install       安装软件包 (例: $0 install python3)"
    echo "  status        显示状态"
    echo "  help          显示帮助"
    echo ""
}

# 主程序
case "$1" in
    login)
        login
        ;;
    start-ssh)
        start_ssh
        ;;
    stop-ssh)
        stop_ssh
        ;;
    install)
        install_pkg "$@"
        ;;
    status)
        status
        ;;
    help|--help|-h)
        help
        ;;
    *)
        echo "未知命令: $1"
        help
        ;;
esac
