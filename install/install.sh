#!/bin/bash

# Settings
user=cdt
home=/home/$user
svnpasswd=$home/.svnpasswd
svnuser=$home/.svnuser

# Check that program is run as root
if [ "$USER" != "root" ] ; then
	echo "ERROR! Installation program must be run as root"
	exit 1
fi

# Prompt for Google user name and password
if [ 0 = 1 ] ; then
	echo "Enter your user name and password. Please be very careful when typing!"
	echo -n "Google code username (email): "
	read user
	echo $user > $svnuser
	echo -n "Google code password: "
	read passwd
	echo $passwd > $svnuser
	chown $user $svnuser $svnpasswd
fi

# Get user and password
cd $home
user=`cat $svnuser`
passwd=`cat $svnpasswd`

# Checkout CDT repository
#rm -r $home/cdt
#svn checkout https://copenhagen-dependency-treebank.googlecode.com/svn/trunk/ cdt --username $user --password $passwd
exit 0

# Download and install debian packages
wget http://www.buch-kromann.dk/cdt/packages.txt
dpkg --set-selections < packages.txt
apt-get dselect-upgrade 

# Extract dtag archive
mkdir -p ~/dtag

#rm /opt/dtag
#rm /usr/local/bin/dtag
#ln -s /home/cdt/dtag /opt/
#ln -s /opt/dtag/dtag /usr/local/bin/dtag
