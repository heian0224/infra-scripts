#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "请使用root权限运行此脚本"
    exit 1
fi

# 检查是否提供了版本参数
if [ -z "$1" ]; then
    echo "错误：请提供Nginx版本号"
    echo "用法：$0 <版本号>"
    echo "例如：$0 1.24.0"
    exit 1
fi

NGINX_VERSION=$1

# 安装依赖
dnf install -y gcc pcre-devel zlib-devel openssl-devel

# 下载或使用已有的 Nginx 源码
cd /tmp
if [ -f "/tmp/Packages/nginx-${NGINX_VERSION}.tar.gz" ]; then
    cp /tmp/Packages/nginx-${NGINX_VERSION}.tar.gz .
elif [ ! -f "nginx-${NGINX_VERSION}.tar.gz" ]; then
    wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
fi
tar xzf nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}

# 配置和编译
./configure \
    --prefix=/usr/local/nginx \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-threads \
    --with-file-aio \
    --with-stream \
    --with-stream_ssl_module
make && make install

# 创建 systemd 服务文件
cat > /usr/lib/systemd/system/nginx.service << 'EOF'
[Unit]
Description=nginx - high performance web server
Documentation=https://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

[Install]
WantedBy=multi-user.target
EOF

# 重新加载 systemd 配置
systemctl daemon-reload

# 启动 Nginx 服务
systemctl start nginx
systemctl enable nginx > /dev/null 2>&1
ln -s /usr/local/nginx/sbin/nginx  /usr/local/bin/

# 验证安装
echo "Nginx 安装完成！"
echo "----------------------------------------"
echo "Nginx 版本："
/usr/local/nginx/sbin/nginx -v 2>&1
echo "Nginx 状态：$(systemctl is-active nginx)"
echo "Nginx 配置文件：/usr/local/nginx/conf/nginx.conf"
echo "Nginx 可执行文件：/usr/local/nginx/sbin/nginx"
echo "----------------------------------------" 