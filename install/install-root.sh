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

# Create links to dtag
rm -f /opt/dtag
rm -f /usr/local/bin/dtag
ln -s $cdtdir/dtag /opt/
ln -s $cdtdir /opt/
ln -s /opt/dtag/dtag /usr/local/bin/dtag

# Ask user to download and install debian packages
echo "Please execute the following commands:"
echo "    dpkg --set-selections < $installdir/packages.txt"
echo "    apt-get dselect-upgrade"



