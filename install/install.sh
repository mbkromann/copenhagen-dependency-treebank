#!/bin/bash

# Settings
user=cdt
home=/home/$user
svnpasswd=$home/.svnpasswd
svnuser=$home/.svnuser
cdtdir=$home/cdt
installdir=$cdtdir/install

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
username=`cat $svnuser`
password=`cat $svnpasswd`

# Checkout CDT repositorym -r $home/cdt
if [ ! -d cdt ] ; then
	svn checkout https://copenhagen-dependency-treebank.googlecode.com/svn/trunk/ cdt --username $username --password $password
else
	echo "ERROR: Directory $home/cdt already exists!"
	#exit 1
fi


# Download and install debian packages
echo "Please enter the Ubuntu password for $user when/if prompted for it"
echo "Setting packages to install"
sudo dpkg --set-selections < $installdir/packages.txt
echo "Installing packages"
sudo apt-get dselect-upgrade 
exit 0

# Extract dtag archive
mkdir -p ~/dtag

#rm /opt/dtag
#rm /usr/local/bin/dtag
#ln -s /home/cdt/dtag /opt/
#ln -s /opt/dtag/dtag /usr/local/bin/dtag
