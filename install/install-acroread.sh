#!/bin/bash

# Gain root access
#if [ `whoami` -ne "root" ] ; then
#	echo "Please type your password below"
#	sudo ~/cdt/install/updates/02-install-acroread.sh
#	exit 0
#fi

# Remove evince
sudo apt-get remove evince

# Install acroread
echo "deb http://packages.medibuntu.org/ hardy free non-free" | sudo tee -a /etc/apt/sources.list

wget -q http://packages.medibuntu.org/medibuntu-key.gpg -O- | sudo apt-key add - && sudo apt-get update

sudo apt-get remove mozplugger && sudo apt-get install acroread acroread-plugins mozilla-acroread mozplugger flashplugin-nonfree

