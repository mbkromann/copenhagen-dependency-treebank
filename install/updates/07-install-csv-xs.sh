#!/bin/bash

if aptitude search libtext-csv-perl | grep -v '^i' ; then 
	echo "Installing libtext-csv-xs-perl"
	echo "Please enter your password below"
	sudo apt-get install libtext-csv-xs-perl || exit 1
fi

