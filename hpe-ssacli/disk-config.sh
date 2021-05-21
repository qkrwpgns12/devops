#!/bin/bash

### Configure RAID in HPE SmartArray Controller ###
# line=`ssacli ctrl all show config | grep physicaldrive | awk '{ print $2 }'`
line=`ssacli ctrl slot=0 pd allunassigned show | grep physicaldrive | awk '{ print $2 }'`

echo "=========================================";
echo "Start Configuring RAID ------------------";
for i in $line
do
ssacli ctrl slot=0 create type=ld drives=$i raid=0
done
sleep 1
echo "Complete --------------------------------";



### Partitioning Physical Drive ###

echo "=========================================";
echo "Copy Original /etc/fstab to /etc/fstab.bak"
cp /etc/fstab /etc/fstab.bak
echo "Copy Complete"

echo "=========================================";
echo "Start Physical Drive Partitioning -------";
j=1
for i in {b..m}
do
parted --script /dev/sd$i mklabel gpt mkpart primary xfs 1049kb 100% set 1;
echo "/dev/sd$i"1" /DATA$j xfs defaults 0 0" >> /etc/fstab;
j=$((j+1));
done
sleep 1
echo "Complete -------------------------------";



echo "========================================";
echo "Start Making Filesystem ----------------";
for i in {b..m}
do
mkfs.xfs -f "/dev/sd"$i"1";
done
sleep 1
echo "Complete -------------------------------";

echo "========================================";
echo "Start Mounting -------------------------";
mount -a;
sleep 1
echo "Complete -------------------------------";
echo "========================================";


ssacli ctrl all show config
df -Th
cat /etc/fstab
