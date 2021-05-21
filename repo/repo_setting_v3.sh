#!/bin/bash

### Checking iso9660 device ###
iso_dev=`blkid | grep iso9660 | cut -d ":" -f 1`

### umount auto mountpoint in graphical.target ###
if [ `systemctl get-default` = "graphical.target" ]; then
	umount /run/media/`whoami`/*
fi

if [ "$iso_dev" = "" ]; then
	echo "Device not found"
	echo "Check CD/DVD is inserted" 
	exit
fi

if [ `df -Th | grep iso9660 | wc -l` -ge '1' ] || [ `blkid | grep iso9660 | wc -l` -ge '2' ]; then
	echo 
	echo "Check mountpoints. already configured local repository"
	echo "----------------------------------------------------"
	df -Th | grep iso9660
	exit
fi


### Main ###

os=`cat /etc/os-release | grep ID | head -1 | cut -d "\"" -f 2`
version=`cat /etc/os-release | grep VERSION_ID| cut -d "\"" -f 2 | sed 's/[^0-9\]//'`
iso_name=$os$version


### duplicate iso file ###
echo "Starting duplicate iso file ... "
dd if=$iso_dev of=/$iso_name.iso

echo "Success. created iso file."


### /etc/fstab modify ###
echo "----------------------------------------------------"
echo "Modifying /etc/fstab ..."
echo -e "/$iso_name.iso\t\t/repo\tiso9660\tloop\t0 0" >> /etc/fstab
tail -n 1 /etc/fstab
echo "Done"
	
echo "----------------------------------------------------"
echo "repo FILE creating ..."


### repository create ###
if [ $version -ge 80 ]; then

	echo " BaseOS repo creating... "
	repo=/etc/yum.repos.d/$iso_name-BaseOS.repo
	touch $repo
		
	echo "[$iso_name-BaseOS]" > $repo
	echo "name=$iso_name-BaseOS" >> $repo
	echo "baseurl=file:///repo-BaseOS" >> $repo
	echo "gpgcheck=0" >> $repo
	echo "enabled=1" >> $repo
	echo "Done. BaseOS repo is created"

	echo " AppStream repo creating... "
	repo=/etc/yum.repos.d/$iso_name-AppStream.repo
	touch $repo
			
	echo "[$iso_name-AppStream]" > $repo
	echo "name=$iso_name-AppStream" >> $repo
	echo "baseurl=file:///repo-AppStream" >> $repo
	echo "gpgcheck=0" >> $repo
	echo "enabled=1" >> $repo
	echo "Done. AppStream repo is created"
else
	repo=/etc/yum.repos.d/$iso_name.repo
	touch $repo

	echo "[$iso_name]" > $repo
	echo "name=$iso_name" >> $repo
	echo "baseurl=file:///repo" >> $repo
	echo "gpgcheck=0" >> $repo
	echo "enabled=1" >> $repo
	echo "Done. repo is created"
fi

mkdir /repo	
	
echo "----------------------------------------------------"
echo "mounting ... "
mount -a
df -Th | grep repo

yum clean all
yum repolist

echo "Done."
exit
