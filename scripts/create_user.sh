#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "请使用root权限运行此脚本"
    exit 1
fi

# 检查是否提供了用户名和密码参数
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "错误：请提供用户名和密码作为参数"
    echo "用法：$0 <用户名> <密码>"
    exit 1
fi

USERNAME=$1
PASSWORD=$2

# 创建用户
useradd -m -d /home/$USERNAME $USERNAME

# 设置密码
echo "$USERNAME:$PASSWORD" | chpasswd

# 确保主目录存在并设置权限
mkdir -p /home/$USERNAME
chown $USERNAME:$USERNAME /home/$USERNAME
chmod 700 /home/$USERNAME

# 添加到必要的用户组（根据需要修改）
usermod -aG wheel $USERNAME

echo "用户创建成功！"
echo "用户名: $USERNAME"
echo "密码: $PASSWORD"
echo "主目录: /home/$USERNAME" 