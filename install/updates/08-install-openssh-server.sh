#!/bin/bash

if aptitude search openssh-server | grep -v '^i' ; then 
	echo "Installing openssh-server"
	echo "Please enter your password below"
	sudo apt-get install openssh-server || exit 1
fi

