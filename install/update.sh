#!/bin/bash

echo "Updating CDT... please wait"

# Update CDT repository
cd ~/cdt-all
svn update --username `cat ~/.svnuser` --password `cat ~/.svnpasswd`

# Copy desktop icons to desktop
echo Updating desktop icons
cp ~/cdt/install/*.desktop ~/Desktop

# Run update program
updates=~/cdt-all/trunk/install/updates
if [ -d $updates ] ; then
	cd $updates
	export LANG=C
	for f in `ls | sort | grep .sh | sed -e 's/.sh$//g'` ; do
		if [ ! -f ".$f.done" ] ; then
			echo "Applying update $f"
			bash $f.sh && touch ".$f.done"
			echo $f > .last
		fi
	done
	if [ -f .last ] ; then
		echo ""
		echo "Last update: " `cat .last`
	fi
fi

# Update local copy of treebank.dk
echo
echo "YOU CAN START DTAG NOW!"
echo
echo "Updating local copy of www.treebank.dk"
cd ~
if [ ! -d web ] ; then
	mkdir -p web 
	cd web
	httrack -w www.treebank.dk && ln -s httrack/www.treebank.dk treebank.dk
fi
cd web
httrack --update

# Finish
echo ""
echo "Update complete!"
echo "Please press enter to close the update window"
read enter
