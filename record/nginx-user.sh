vi install_nginx.sh

sh -x install_nginx.sh  1.24.0
sudo groupadd nginxgroup
sudo useradd -g nginxgroup -s /sbin/nologin -M nginxuser
mkdir -p /data/cert/
mv /data/sftp/sftp-user/liucongblog.com.pem /data/cert/.
mv /data/sftp/sftp-user/futurefantasy.tech.key /data/cert/.
mv /data/sftp/sftp-user/futurefantasy.tech.pem /data/cert/.
chown nginxuser:nginxgroup -R cert
cd /usr/local/nginx/conf
ls -ll
rm nginx.conf
vi nginx.conf


mkdir -p /var/log/nginx
chown -R nginxuser:nginxgroup /var/log/nginx

gpasswd -a nginxuser sftp-user
mkdir -p /data/sftp/sftp-user/liucongblog/
mkdir -p  /data/sftp/sftp-user/futurefantasy/
