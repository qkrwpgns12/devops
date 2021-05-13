#!/bin/bash

### RHEL,CentOS 7.x Version ###
echo "-------------------------------------"
echo "NetworkManager Disable..."
#systemctl stop NetworkManager
#systemctl disable NetworkManager
systemctl status NetworkManager
echo "Done!"

echo "-------------------------------------"
echo "Firewall Disable"
systemctl stop firewalld
systemctl disable firewalld
echo "Done!"

echo "-------------------------------------"
echo "selinux Disable"
if [ `getenforce` = "Disabled" ]; then
	echo "already selinux disabled"
else
	sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
fi
echo "Done!"
