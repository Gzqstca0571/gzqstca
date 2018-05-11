#!/bin/bash
while [ $[i+=1] -lt 255 ]
do
ping -i0.1 -W1 -c2 176.19.4.$i &>/dev/null
if [ $? -eq 0 ];then
echo "176.19.4.$i主机存活">>/root/ip.txt
else
echo "176.19.4.$i主机不可达"

fi
done
