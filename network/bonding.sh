#!/bin/bash

echo "-------------------------------------------------------------------"
echo "Bond Interface Setting..."

echo "show bond interface list..."
DIR=/etc/sysconfig/network-scripts

ls -al $DIR | grep ifcfg-bond\*

printf "Bond Interface Name: "
read bond

FILE=$DIR/ifcfg-$bond


echo "-------------------------------------------------------------------"
### Bond Interface Check ###
if [ -f $FILE ]; then
        cat $FILE
        echo "-------------------------------------------------------------------"
        echo "already file exists!"
        exit
fi


### Slave Interface Check ###
echo "show slave interface list..."
ls -al $DIR | grep ifcfg-\*

printf "Select First Slave Interface: "
read int1

if [ ! -f $DIR/ifcfg-$int1 ]; then
        echo "No file: ifcfg-$int1"
        exit
fi

printf "Select Second Slave Interface: "
read int2

if [ ! -f $DIR/ifcfg-$int2 ]; then
        echo "No file: ifcfg-$int2"
        exit
fi


### First Slave Interface Setting ###
sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/g' $DIR/ifcfg-$int1
sed -i 's/ONBOOT=no/ONBOOT=yes/g' $DIR/ifcfg-$int1
echo "MASTER=$bond" >> $DIR/ifcfg-$int1
echo "SLAVE=yes" >> $DIR/ifcfg-$int1
echo "-------------------------------------------------------------------"
echo "Information: ifcfg-$int1 ..."
cat $DIR/ifcfg-$int1
echo "-------------------------------------------------------------------"

### Second Slave Interface Setting ###
sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/g' $DIR/ifcfg-$int2
sed -i 's/ONBOOT=no/ONBOOT=yes/g' $DIR/ifcfg-$int2
echo "MASTER=$bond" >> $DIR/ifcfg-$int2
echo "SLAVE=yes" >> $DIR/ifcfg-$int2
echo "Information: ifcfg-$int2 ..."
cat $DIR/ifcfg-$int2
echo "-------------------------------------------------------------------"


### Bond Interface Setting ###
touch $FILE
touch /etc/modprobe.d/bonding.conf

read -p "IP address: " ipv4
read -p "Netmask: " netmask
read -p "Gateway: " gateway

echo "DEVICE=$bond" >> $FILE
echo "NAME=$bond" >> $FILE
echo "TYPE=Ethernet" >> $FILE
echo "BOOTPROTO=none" >> $FILE
echo "ONBOOT=yes" >> $FILE
echo "IPADDR=$ipv4" >> $FILE
echo "NETMASK=$netmask" >> $FILE
echo "GATEWAY=$gateway" >> $FILE
echo "BONDING_OPTS=\"miimon=100 updelay=0 downdelay=0 mode=active-backup\"" >> $FILE

echo "alias $bond bonding" >> /etc/modprobe.d/bonding.conf

echo "-------------------------------------------------------------------"
echo "$FILE create!"
echo "-------------------------------------------------------------------"
echo "Information: ifcfg-$bond ... "
cat $FILE
echo "-------------------------------------------------------------------"
echo "/etc/modprobe.d/bonding.conf create!"

cat /etc/modprobe.d/bonding.conf
echo "-------------------------------------------------------------------"

echo "-------------------------------------------------------------------"
echo "Network Restarting..."
systemctl restart network
echo "-------------------------------------------------------------------"
echo "Done!"

