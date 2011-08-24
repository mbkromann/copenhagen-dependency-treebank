#!/bin/bash

# Settings
user=$USER
home=/home/$user
svnpasswd=$home/.svnpasswd
svnuser=$home/.svnuser
cdtuser=$home/.cdtname
cdtdir=$home/cdt
installdir=$cdtdir/install

# Prompt for Google user name and password
if [ ! -f $svnuser ] ; then
	echo "Enter your user name and password. Please be very careful when typing!"
	echo -n "Google code username (email OR blank if unknown): "
	read guser
	echo $guser > $svnuser

	echo -n "Google code password (blank if username is blank): "
	read gpasswd
	echo $gpasswd > $svnpasswd

	echo -n "CDT user name (eg, morten): "
	read name
	echo $name > $cdtuser

	#chown $user $svnuser $svnpasswd
fi

# Get user and password
cd $home
username=`cat $svnuser`
password=`cat $svnpasswd`

# Checkout CDT repositorym -r $home/cdt
if [ ! -d cdt-all ] ; then
	rm -rf cdt
	if [ -z "$username" ] ; then
		svn checkout http://copenhagen-dependency-treebank.googlecode.com/svn cdt-all
	else 
		svn checkout https://copenhagen-dependency-treebank.googlecode.com/svn cdt-all --username $username --password $password
	fi		
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
if ps aux | grep xfce | grep -v grep ; then
	echo "XFCE desktop (eg, Xubuntu): copying XFCE desktop icons"
fi

