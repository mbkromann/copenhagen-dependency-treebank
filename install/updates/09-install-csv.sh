#!/bin/bash

if aptitude search libtext-csv-perl | grep -v '^i' ; then 
	echo "Installing libtext-csv-perl"
	echo "Please enter your password below"
	sudo apt-get install libtext-csv-perl || exit 1
fi

