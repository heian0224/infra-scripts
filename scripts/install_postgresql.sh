#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "请使用root权限运行此脚本"
    exit 1
fi

# 检查参数
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "错误：请提供PostgreSQL版本号和密码"
    echo "用法：$0 <版本号> <密码>"
    echo "例如：$0 14 mypassword"
    exit 1
fi

PG_VERSION=$1
DB_PASSWORD=$2
PG_LISTEN_PORT=6432
# 安装 PostgreSQL 仓库并导入 GPG 密钥
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
# rpm --import /etc/pki/rpm-gpg/PGDG-RPM-GPG-KEY-RHEL

# 禁用内置的 PostgreSQL 模块
dnf -qy module disable postgresql

# 安装指定版本的 PostgreSQL
dnf install -y postgresql${PG_VERSION}-server postgresql${PG_VERSION}

# 初始化数据库
/usr/pgsql-${PG_VERSION}/bin/postgresql-${PG_VERSION}-setup initdb

# 配置远程访问
PG_CONF="/var/lib/pgsql/${PG_VERSION}/data/postgresql.conf"
PG_HBA="/var/lib/pgsql/${PG_VERSION}/data/pg_hba.conf"

# 修改 postgresql.conf
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $PG_CONF
sed -i "s/#port = 5432/port = ${PG_LISTEN_PORT}/" $PG_CONF
# 修改 pg_hba.conf，添加允许所有IP访问
echo "host    all             all             0.0.0.0/0               md5" >> $PG_HBA

# 启动 PostgreSQL 服务
systemctl enable postgresql-${PG_VERSION}
systemctl start postgresql-${PG_VERSION}

# 设置 postgres 用户密码
su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD '${DB_PASSWORD}';\""

# 检查服务状态
if systemctl is-active --quiet postgresql-${PG_VERSION}; then
    echo "PostgreSQL ${PG_VERSION} 安装并启动成功！"
    echo "服务状态：运行中"
else
    echo "PostgreSQL ${PG_VERSION} 安装成功但服务启动失败，请检查日志"
    exit 1
fi

# 显示版本信息
su - postgres -c "psql -V"

echo "PostgreSQL ${PG_VERSION} 安装完成！"
echo "默认数据目录：/var/lib/pgsql/${PG_VERSION}/data/"
echo "监听端口调整为： ${PG_LISTEN_PORT}"
echo "数据库已配置允许远程访问"
echo "postgres 用户密码已设置为：${DB_PASSWORD}" 