#!/bin/bash -vx

home=/home/cdt
cdtdir=$home/cdt-all/trunk
installdir=$cdtdir/install
user=`cat $home/.cdtname`
export LANG=en_DK.UTF-8

# This update only applies to iørn
if cat $home/.cdtname | egrep -v "(iørn|iorn)" ; then
	echo "This update only applies to Iørn's computer"
else
	echo "Updating Iørn's computer"

	# Find all files with iørn and rename to iorn
	cd $cdtdir
	for f in `ls $cdtdir/todo/i*rn ; find $cdtdir/ -print | egrep '[-]i[^-]*rn' | grep -v svn | grep -v malt | grep tag` ; do
		g=`echo $f | sed -e 's/-i[^-]*rn/-iorn/g'`
		echo svn mv `ls $f` $g
		svn mv `ls $f` $g
	done

	# Rename cdtname iørn to iorn
	echo "iorn" > $home/.cdtname
	
	# Rename tasks in todo
	cat $cdtdir/todo/i?rn | sed -e 's/-i[^-]*rn/-iorn/g' > /tmp/iorn
	mv /tmp/iorn $cdtdir/todo/iorn

	# Instruct Iørn to restart
	echo "PLEASE restart DTAG now"
fi


