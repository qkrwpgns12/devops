#!/bin/bash

### NetworkManager setting ###
if [ `cat /etc/os-release | grep VERSION_ID | sed -n 's/[^0-9]//gp'` -ge '80' ]; then
	echo "This System OS over than 8 ..."
	echo "Done."
else
	echo "Starting NetworkManager stop/disable ... "
	systemctl stop NetworkManager
	systemctl disable NetworkManager
	echo "Done."
fi

### firewalld setting ###
echo "-------------------------------------"
echo "Firewall stop/disable ..."
systemctl stop firewalld
systemctl disable firewalld
echo "Done."

### selinux setting ###
echo "-------------------------------------"
echo "selinux disable ..."

if [ `getenforce` = "Disabled" ]; then
	echo "selinux already disabled"
else
	sed -i --follow-symlinks 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux
	sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
fi
echo "Done. Changes will be apply after reboot!"

### Change Hostname ###
read -p "Would you change hostname? [y/n]: " reply
if [ $reply = "y" ] || [ $reply = "yes" ]; then
	echo "-------------------------------------"
	read -p "hostname: " hostname
	hostnamectl set-hostname $hostname
	echo "Done. Changes will be apply after reboot!"
else
	echo "No Change hostname"
fi

