#!/bin/bash

url="http://ftp.dk.debian.org/debian/pool/main/libp/libparse-recdescent-perl/libparse-recdescent-perl_1.965001+dfsg-1_all.deb"
file="libparse-recdescent-perl_1.965001+dfsg-1_all.deb"
wget $url

echo "Update libparse-recdescent-perl to newest version"
echo "Please enter your password below"
sudo dpkg -i $file
rm $file

