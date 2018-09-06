echo "This is Zabbix server !!! make with Centos7,mariadb,apache"
echo "web is http://zabbix_host_ip/zabbix"
echo "Zabbix_web username: admin  password: zabbix"
read -p "push mysql password to continue:(you need remember!!!)" sqlpasswd
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo &>/dev/null
#yum clean all
#yum update
rpm -ivh https://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm &>/dev/null
yum install zabbix-server-mysql zabbix-web-mysql zabbix-agent &>/dev/null
yum -y install mariadb mariadb-server.x86_64 &>/dev/null
systemctl restart mariadb mariadb.service &>/dev/null
systemctl enable mariadb mariadb.service &>/dev/null
mysql -e "set password for root@localhost=password($sqlpasswd);"
mkdir -p /backup/mysql &>/dev/null
mysqldump -uroot -p"$sqlpasswd" mysql.user > /backup/mysql/user.sql
mysql -uroot -p"$sqlpasswd" -e "delete from mysql.user where password='';"
mysql -uroot -p"$sqlpasswd" -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -uroot -p"$sqlpasswd" -e "grant all privileges on zabbix.* to zabbix@'localhost' identified by 'zabbix';"
zcat /usr/share/doc/zabbix-server-mysql-3.4.13/create.sql.gz | mysql -uzabbix -pzabbix zabbix
sed -i "s/# DBHost=.*/DBHost=localhost/" /etc/zabbix/zabbix_server.conf &>/dev/null
sed -i "s/DBName=.*/DBName=zabbix/"      /etc/zabbix/zabbix_server.conf &>/dev/null
sed -i "s/# DBUser=.*/DBUser=zabbix/"    /etc/zabbix/zabbix_server.conf &>/dev/null
sed -i "s/# DBPassword=.*/DBPassword=zabbix/" /etc/zabbix/zabbix_server.conf &>/dev/null
sed -i "s#LogFile=/.*#LogFile=/tmp/zabbix_server.log#" /etc/zabbix/zabbix_server.conf &>/dev/null
sed -i "#php_value date.timezone.*#php_value date.timezone Asia/Shanghai#" /etc/httpd/conf.d/zabbix.conf &>/dev/null
sed -i "s/SELINUX=.*/SELINUX=disabled/" /etc/selinux/config &>/dev/null
systemctl restart httpd &>/dev/null
setenforce 0
systemctl stop firewalld &>/dev/null
yum -y remove firewalld &>/dev/null
