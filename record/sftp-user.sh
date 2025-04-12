chmod +x create_user.sh
sh -x create_user.sh sftp-user xxx

useradd sftp-user -s /sbin/nologin
echo 'Subsystem sftp internal-sftp  #指定使用sftp服务使用系统自带的internal-sftp 
Match user  sftp-user         #匹配用户，如果要匹配多个组，多个组之间用逗号分割
ChrootDirectory  /data/sftp   #设定属于用户组sftp的用户访问的根文件夹如设置    /data/sftp   作为sftpuser        的sftp根目录
ForceCommand internal-sftp #指定sftp命令,强制执行内部sftp，并忽略任何    ~/.ssh/rc文件中的命令'  >> /etc/ssh/sshd_config

mkdir /data/sftp -m 750 -p
chown root.sftp-user  /data/sftp
mkdir -p /data/sftp/sftp-user 
chown sftp-user.sftp-user  /data/sftp/sftp-user 

 
mkdir -p /home/sftp-user/.ssh
cd /home/sftp-user
chown sftp-user:sftp-user  .ssh
vi authorized_keys

chown sftp-user.sftp-user  authorized_keys
