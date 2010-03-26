#!/bin/bash

user=$1
if [ -z "$user" ] ; then
	user=$SUDO_USER
fi
if [ -z "$user" ] ; then
	echo "ERROR: Cannot guess your username."
	echo "Please specify it with 'sh install-root.sh <username>'"
	exit 1
fi
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

# Create links to home directory
if [ ! -e /home/cdt ] ; then
	user2=`cd /home; ls | head -1`
	ln -s /home/$cdt /home/$user
fi

# Create links to dtag
rm -f /opt/dtag /opt/cdt
rm -f /usr/local/bin/dtag
ln -s $cdtdir/dtag /opt/
ln -s $cdtdir /opt/
ln -s /opt/dtag/dtag /usr/local/bin/dtag

# Ask user to download and install debian packages
cd /tmp
wget http://www.buch-kromann.dk/cdt/packages.txt
apt-get update
dpkg --set-selections < packages.txt
apt-get dselect-upgrade

# Further instructions
cd $home
wget http://www.buch-kromann.dk/cdt/install.sh
echo "Please logout as root by typing 'exit'."
echo "Then run the command 'sh install.sh'."

