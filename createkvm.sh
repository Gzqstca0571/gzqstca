#!/bin/bash
read -p "请输入需要创建的虚拟机数量：" num
read -p "请输入起始的虚拟机编号：node" x

for i in `seq $num`
do
cp /root/node.xml /var/lib/libvirt/qemu/node$[i-1+x].xml
sed -i 's/name>node.*</name>node'$[i-1+x]'</' /var/lib/libvirt/qemu/node$[i-1+x].xml
sed -i 's/node.*.qcow2/node'$[i-1+x]'.img/' /var/lib/libvirt/qemu/node$[i-1+x].xml
virsh define /var/lib/libvirt/qemu/node$[i-1+x].xml
qemu-img create -b /var/lib/libvirt/images/node.qcow2 -f qcow2 /var/lib/libvirt/images/node$[i-1+x].img
done
