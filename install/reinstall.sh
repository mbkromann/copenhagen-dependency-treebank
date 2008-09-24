#!/bin/bash

# Settings
user=cdt
home=/home/$user
svnpasswd=$home/.svnpasswd
svnuser=$home/.svnuser
cdtdir=$home/cdt
cdtname=$home/.cdtname
installdir=$cdtdir/install

# Delete Google user name and password, and move directories to /tmp
cd $home
tmpdir="/tmp/cdt.`date +%Y%m%d`"
mkdir $tmpdir
mv -f $svnuser $svnpasswd .cdtuser cdt-all cdt $tmpdir

# Prompt for Google user name and password
if [ ! -f $svnuser ] ; then
	echo "Enter your user name and password. Please be very careful when typing!"
	echo -n "Google code username (email): "
	read user
	echo $user > $svnuser
	echo -n "Google code password: "
	read passwd
	echo $passwd > $svnpasswd
	chown $user $svnuser $svnpasswd
	echo -n "CDT name (eg, morten)"
	read usercdt
	echo $usercdt > $cdtuser
fi

# Get user and password
cd $home
username=`cat $svnuser`
password=`cat $svnpasswd`

# Checkout CDT repositorym -r $home/cdt
if [ ! -d cdt-all ] ; then
	rm -rf cdt
	svn checkout https://copenhagen-dependency-treebank.googlecode.com/svn cdt-all --username $username --password $password
	ln -s $home/cdt-all/trunk $home/cdt
	ln -s $home/cdt-all/wiki $home/cdt/wiki
else
	echo "ERROR: Directory $home/cdt already exists!"
fi

# Copy icons to desktop
if ps aux | grep gnome | grep -v grep > /dev/null ; then
	echo "Gnome desktop (eg, Ubuntu): copying Gnome desktop icons"
	cp $installdir/gnome/*.desktop $home/Desktop
fi
if ps aux | grep xfce | grep -v grep
	echo "XFCE desktop (eg, Xubuntu): copying XFCE desktop icons"
fi

# Extract dtag archive
echo
echo "Please log in as root and execute the following command:"
echo "    sh $installdir/install-root.sh"


