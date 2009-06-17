#!/bin/bash

home=/home/cdt
cdtdir=$home/cdt-all/trunk
installdir=$cdtdir/install
user=`cat $home/.cdtname`

# This update only applies to iørn
if cat $home/.cdtname | egrep "(iørn|iorn)" ; then
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
	
	# Rename tasks in todo
	cat $cdtdir/todo/iorn | sed -e 's/iørn/iorn/g' > /tmp/iorn
	mv /tmp/iorn $cdtdir/todo/iorn

	# Instruct Iørn to restart
	echo "PLEASE restart DTAG now"
fi


