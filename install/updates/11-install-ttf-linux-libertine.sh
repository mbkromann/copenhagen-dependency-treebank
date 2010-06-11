#!/bin/bash

package=ttf-linux-libertine
if aptitude search $package | grep -v '^i' ; then 
	echo "Installing ttf-linux-libertine"
	echo "Please enter your password below"
	sudo apt-get install ttf-linux-libertine || exit 1
fi

