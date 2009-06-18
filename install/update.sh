#!/bin/bash

echo "Updating CDT... please wait"

# Update CDT repository
cd ~/cdt-all
svn update --username `cat ~/.svnuser` --password `cat ~/.svnpasswd`

# Copy desktop icons to desktop
echo Updating desktop icons
if ps aux | grep -v grep | grep gnome-session > /dev/null ; then
    echo "Updating Gnome desktop icons"
	cp ~/cdt/install/gnome/*.desktop ~/Desktop
fi
if ps aux | grep -v grep | grep xfce-mcs-manage > /dev/null ; then
    echo "Updating XFCE desktop icons"
	cp ~/cdt/install/xfce/*.desktop ~/Desktop
fi

# Run update program
updates=~/cdt-all/trunk/install/updates
user=`cat ~/.cdtname | sed -e 's/i.*rn/iorn/g'`
if [ -d $updates ] ; then
	cd $updates
	export LANG=C
	for f in `ls | sort | grep .sh | sed -e 's/.sh$//g'` ; do
		logfile=~/cdt-all/trunk/install/logs/$user-$f.log
		if [ ! -f ".$f.done" ] ; then
			echo "Applying update $f"
			bash $f.sh 2>&1 | tee $logfile && touch ".$f.done" 
			echo $f > .last
			svn add $logfile
		fi
	done
	if [ -f .last ] ; then
		echo ""
		echo "Last update: " `cat .last`
	fi
fi

# Create printout directory
mkdir -p ~/Desktop/CDT-prints

# Update local copy of treebank.dk
echo
echo "YOU CAN START DTAG NOW!"
echo
echo "Updating local copy of www.treebank.dk"
cd ~
if [ ! -d web/treebank.dk ] ; then
	rm -rf ~/web
	mkdir -p web 
	cd ~/web
	svn co svn://disk.buch-kromann.dk/cdt treebank.dk
	ln -s treebank.dk www.treebank.dk
fi
if [ -d ~/web/treebank.dk ] ; then
	cd web/treebank.dk
	svn update
fi

# Finish
echo ""
echo "Update complete!"
echo "Please press enter to close the update window"
read enter
