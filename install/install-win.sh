#!/bin/bash

# Settings
echo -n "Enter you user-name, (e.g. mwh.isv): "
read user
# user=mwh.isv
home=~$user
echo $home
svnpasswd=$home/.svnpasswd
svnuser=$home/.svnuser
cdtdir=$home/cdt
installdir=$cdtdir/install

echo $svnuser

# Prompt for Google user name and password
if [ ! -f "$svnuser" ] ; then
	echo "Enter your user name and password. Please be very careful when typing!"
	echo -n "Google code username (email): "
	read user
	echo $user > "$svnuser"
	echo -n "Google code password: "
	read passwd
	echo "$passwd" > "$svnpasswd"
	chown $user "$svnuser" "$svnpasswd"
fi

# Get user and password
cd "$home"
username=`cat "$svnuser"`
password=`cat "$svnpasswd"`


