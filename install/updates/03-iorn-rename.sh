#!/bin/bash

home=$HOME
cdtdir=$home/cdt
installdir=$cdtdir/install
user=`cat $home/.cdtname`

# This update only applies to iørn
if cat $home/.cdtname | grep "iørn" ; then
	echo "This update only applies to Iørn's computer"
else
	# Find all files with iørn and rename to iorn
	cd $cdtdir
	for f in `echo $cdtdir/todo/iørn ; find $cdtdir/ | grep iørn | grep -v svn | grep -v malt | grep tag` ; do
		g=`echo $f | sed -e 's/iørn/iorn/g'`
		echo svn mv $f $g
	done

	# Rename cdtname iørn to iorn
	echo "iorn" > $home/.cdtname
	
	# Instruct Iørn to restart
	echo "PLEASE restart DTAG now"
fi


