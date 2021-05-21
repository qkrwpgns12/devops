#!/bin/bash

### Checking iso9660 device ###
iso_dev=`blkid | grep iso9660 | cut -d ":" -f 1`

if [ `df -Th | grep iso9660 | wc -l` -ge '3' ] || [ `blkid | grep iso9660 | wc -l` -ge '3' ]; then
	echo 
	echo "Check mountpoints. already configured local repository"
	echo "----------------------------------------------------"
	df -Th | grep iso9660
else
	os=`cat /etc/os-release | grep ID | head -1 | cut -d "\"" -f 2`
	version=`cat /etc/os-release | grep VERSION_ID| cut -d "\"" -f 2 | sed 's/[^0-9\]//'`
	iso_name=$os$version


	### duplicate iso file ###
	echo "Starting duplicate iso file ... "
	dd if=$iso_dev of=/$iso_name.iso

	echo "----------------------------------------------------"
	echo "complete to create iso file."


	### /etc/fstab modify ###
	echo "----------------------------------------------------"
	echo "Modifying /etc/fstab ..."
	echo -e "/$iso_name.iso\t\t/repo\tiso9660\tloop\t0 0" >> /etc/fstab
	echo "Done"
	
	echo "----------------------------------------------------"
	echo "repo FILE creating ..."


	### repository create ###
	if [ $version -ge 80 ]; then

		echo " BaseOS repo creating... "
#		repo=/etc/yum.repos.d/$iso_name-BaseOS.repo
#		touch $repo
		
#		echo "[$iso_name-BaseOS]" > $repo
#		echo "name=$iso_name-BaseOS" >> $repo
#		echo "baseurl=file:///repo-BaseOS" >> $repo
#		echo "gpgcheck=0" >> $repo
#		echo "enabled=1" >> $repo
		echo "BaseOS Done"

		echo " AppStream repo creating... "
#		repo=/etc/yum.repos.d/$iso_name-AppStream.repo
#		touch $repo
				
#		echo "[$iso_name-AppStream]" > $repo
#		echo "name=$iso_name-AppStream" >> $repo
#		echo "baseurl=file:///repo-AppStream" >> $repo
#		echo "gpgcheck=0" >> $repo
#		echo "enabled=1" >> $repo
		echo "AppStream Done"
	else
		repo=/etc/yum.repos.d/$iso_name.repo
		touch $repo

		echo "[$iso_name]" > $repo
		echo "name=$iso_name" >> $repo
		echo "baseurl=file:///repo" >> $repo
		echo "gpgcheck=0" >> $repo
		echo "enabled=1" >> $repo
		echo "Done"
	fi

	mkdir /repo	
	
	echo "----------------------------------------------------"
	echo "mounting ... "
	mount -a

	yum clean all
	yum repolist

	echo "Done"
fi
