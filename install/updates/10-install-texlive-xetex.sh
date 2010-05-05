#!/bin/bash

if aptitude search texlive-xetex | grep -v '^i' ; then 
	echo "Installing texlive-xetex"
	echo "Please enter your password below"
	sudo apt-get install texlive-xetex || exit 1
fi

