#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "请使用root权限运行此脚本"
    exit 1
fi

# 检查是否提供了版本参数
if [ -z "$1" ]; then
    echo "错误：请提供Python版本号"
    echo "用法：$0 <版本号>"
    echo "例如：$0 3.13.3"
    exit 1
fi

PYTHON_VERSION=$1

# 安装依赖
dnf groupinstall -y "Development Tools"
dnf install -y openssl-devel bzip2-devel libffi-devel zlib-devel readline-devel sqlite-devel

# 下载或使用已有的 Python 源码
if [ -f "/tmp/packages/Python-${PYTHON_VERSION}.tgz" ]; then
    cp /tmp/packages/Python-${PYTHON_VERSION}.tgz .
elif [ ! -f "Python-${PYTHON_VERSION}.tgz" ]; then
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
fi

tar xzf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}
# 创建软链接（覆盖系统 Python）
PYTHON_SHORT_VERSION=$(echo $PYTHON_VERSION | cut -d. -f1-2)
# 删除可能存在的旧链接
rm -f /usr/local/bin/python${PYTHON_SHORT_VERSION}
# 配置和编译
./configure --enable-optimizations
make altinstall

# 创建软链接（覆盖系统 Python）
 
# 删除可能存在的旧链接
rm -f /usr/bin/python${PYTHON_SHORT_VERSION}
rm -f /usr/bin/python3
rm -f /usr/bin/python

# 创建新的软链接
ln -s /usr/local/bin/python${PYTHON_SHORT_VERSION} /usr/bin/python${PYTHON_SHORT_VERSION}
ln -s /usr/bin/python${PYTHON_SHORT_VERSION} /usr/bin/python3
ln -s /usr/bin/python3 /usr/bin/python

# 安装 pip 和必要的依赖
dnf install -y python3-libs

# 下载并安装 pip
# curl https://mirrors.aliyun.com/pypi/get-pip.py -o get-pip.py
# /usr/local/bin/python${PYTHON_SHORT_VERSION} get-pip.py
# 安装 pip 和必要的依赖
rm -f /usr/bin/pip3
rm -f /usr/bin/pip
dnf install -y python3-pip python3-libs
ln -s /usr/local/bin/pip${PYTHON_SHORT_VERSION} /usr/bin/pip3
ln -s /usr/bin/pip3  /usr/bin/pip
# 清理临时文件
cd /tmp
rm -rf Python-${PYTHON_VERSION}*
# rm -f get-pip.py

# 验证安装
PYTHON_PATH="/usr/local/bin/python${PYTHON_SHORT_VERSION}"
PIP_PATH="/usr/local/bin/pip${PYTHON_SHORT_VERSION}"

echo "Python 安装完成！"
echo "Python 版本："
$PYTHON_PATH --version
echo "Pip 版本："
$PIP_PATH --version
echo "Python 路径：${PYTHON_PATH}"
echo "Pip 路径：${PIP_PATH}" 