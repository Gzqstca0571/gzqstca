echo "This is Zabbix server !!! make with Centos7,mariadb,apache"
sleep 3
echo "mysql password is: 13141516 you need remember!!!"
sleep 3
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#yum clean all
#yum update
rpm -ivh https://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm
yum install zabbix-server-mysql zabbix-web-mysql zabbix-agent
yum -y install mariadb mariadb-server.x86_64
systemctl restart mariadb mariadb.service
systemctl enable mariadb mariadb.service
mysql -e "set password for root@localhost=password('13141516');"
mkdir -p /backup/mysql
mysqldump -uroot -p13141516 mysql user > /backup/mysql/user.sql
mysql -uroot -p13141516 -e "delete from mysql.user where password='';"
mysql -uroot -p13141516 -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -uroot -p13141516 -e "grant all privileges on zabbix.* to zabbix@'localhost' identified by 'zabbix';"
zcat /usr/share/doc/zabbix-server-mysql-3.4.13/create.sql.gz | mysql -uzabbix -pzabbix zabbix
sed -i "s/# DBHost=.*/DBHost=localhost/" /etc/zabbix/zabbix_server.conf
sed -i "s/DBName=.*/DBName=zabbix/"      /etc/zabbix/zabbix_server.conf
sed -i "s/# DBUser=.*/DBUser=zabbix/"    /etc/zabbix/zabbix_server.conf
sed -i "s/# DBPassword=.*/DBPassword=zabbix/" /etc/zabbix/zabbix_server.conf
sed -i "s#LogFile=/.*#LogFile=/tmp/zabbix_server.log#" /etc/zabbix/zabbix_server.conf
sed -i "#php_value date.timezone.*#php_value date.timezone Asia/Shanghai#" /etc/httpd/conf.d/zabbix.conf
sed -i "s/SELINUX=.*/SELINUX=disabled/" /etc/selinux/config
systemctl restart httpd
setenforce 0
systemctl stop firewalld
yum -y remove firewalld
echo "http://hostip/zabbix"
echo "user:admin  password:zabbix"
