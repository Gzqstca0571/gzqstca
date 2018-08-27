#!/bin/bash
#yum -y install expect tcl
read -p "请输入虚拟机起始编号(1~*):  node" vm
read -p "请输入需要创建起始ip地址(例:192.168.2.5)：" cip
read -p "请输入需要创建连续的主机数(1~*)：" num
ip=`echo $cip|awk -F. '{print $4}'`
net=`echo $cip|awk -F. '{print $1"."$2"."$3}'`
case $net in
192.168.1)
cnet=eth0;;
192.168.2)
cnet=eth1;;
201.1.1)
cnet=eth2;;
*)
echo "错误的IP地址！"
exit
esac
#for i in `seq $num`
#do
#expect <<eof
#spawn virsh start node$[vm+i-1]
#expect "#" {send "\n"}
#exit
#eof
#done

#sleep 18

for i in `seq $num`
do
echo $net.$[i+ip-1]>>/tmp/host
expect <<EOF
spawn virsh console node$[vm+i-1]
expect "换码符为 ^]" {send "\n"}
expect "login:" {send "root\n"}
expect "Password:" {send "123456\n"}
expect "]#" {send "nmcli connection add con-name $cnet ifname $cnet type ethernet\n"}
expect "]#" {send "nmcli connection modify $cnet ipv4.method manual ipv4.addresses $net.$[i+ip-1]/24 ipv
4.gateway $net.254 ipv4.dns 114.114.114.114 connection.autoconnect yes\n"}expect "]#" {send "nmcli connection up $cnet\n"}
expect "]#" {send "hostnamectl set-hostname node$[i+ip-1].cn\n"}
interact
exit
EOF
done
#yum -y install pssh

for i in `seq $num`
do
expect <<EOF
spawn ssh-copy-id -o StrictHostKeyChecking=no $net.$[ip+i-1]
expect "password:" {send "123456\n"}
expect "#" {send "\n"}
exit
EOF
done

echo 'nmcli connection show| awk '"'/--/{print "'$'"2}'"'>/tmp/et.txt'>/tmp/et.sh
echo for i in '`cat /tmp/et.txt`'>>/tmp/et.sh
echo do >> /tmp/et.sh
echo nmcli connection delete "$"i >>/tmp/et.sh
echo done >> /tmp/et.sh
chmod +x /tmp/et.sh
#pscp.pssh -h /tmp/host /etc/yum.repos.d/gao.repo /etc/yum.repos.d/gao.repo
pscp.pssh -h /tmp/host /tmp/et.sh /tmp/et.sh
pssh -h /tmp/host bash /tmp/et.sh
rm -rf /tmp/host
