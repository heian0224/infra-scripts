vi install_python.sh
chmod +x install_python.sh
sh -x install_python.sh  3.13.3
pip
cd /data/crontab/
ls
sudo dnf -y install python3 augeas-libs
sudo python3 -m venv /opt/certbot/
sudo /opt/certbot/bin/pip install --upgrade pip
sudo /opt/certbot/bin/pip install certbot certbot-nginx
sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot
 
sudo certbot certonly --nginx --nginx-ctl /usr/local/nginx/sbin/nginx --nginx-server-root /usr/local/nginx/conf

echo "0 0,12 * * * root /opt/certbot/bin/python -c 'import random; import time; time.sleep(random.random() * 3600)' && sudo certbot renew --post-hook 'systemctl reload nginx' " | sudo tee -a /etc/crontab > /dev/null
# Certificate is saved at: /etc/letsencrypt/live/futurefantasy.tech/fullchain.pem
# Key is saved at:         /etc/letsencrypt/live/futurefantasy.tech/privkey.pem
# cron log /var/log/cron