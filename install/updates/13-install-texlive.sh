#!/bin/bash

package=texlive-font-utils
if aptitude search $package | grep -v '^i' ; then 
	echo "Installing $package"
	echo "Please enter your password below"
	sudo apt-get install $package || exit 1
fi

