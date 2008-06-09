#!/bin/bash

user=cdt
home=/home/$user
cdtdir=$home/cdt
installdir=$cdtdir/install

# Check that user is root
if [ $USER != "root" ] ; then
	echo "ERROR: You are not root!"
	exit 1
fi

# Backup important disk information
#fdisk -l > $home/.fdisk
#swapdev=`fdisk -l | grep swap | awk '{ print $1 }'`
#dd if=$swapdev of=$home/.swap bs=512 count=100

# Create links to dtag
rm -f /opt/dtag /opt/cdt
rm -f /usr/local/bin/dtag
ln -s $cdtdir/dtag /opt/
ln -s $cdtdir /opt/
ln -s /opt/dtag/dtag /usr/local/bin/dtag

# Ask user to download and install debian packages
cd /tmp
wget http://www.buch-kromann.dk/cdt/packages.txt
dpkg --set-selections < packages.txt
apt-get dselect-upgrade


