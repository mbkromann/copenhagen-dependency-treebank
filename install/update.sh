#!/bin/bash

echo "Updating CDT... please wait"

# Update CDT repository
cd ~/cdt-all
svn update --username `cat ~/.svnuser` --password `cat ~/.svnpasswd`

# Run update program
postupdate=~/cdt-all/trunk/tools/post-update.sh
if [ -f $postupdate ] ; then
	/bin/bash $postupdate
fi

# Finish
echo "Update complete... closing window in 10 seconds"
sleep 10
