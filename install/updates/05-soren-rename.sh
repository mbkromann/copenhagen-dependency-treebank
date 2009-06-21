#!/bin/bash -vx

home=/home/cdt
cdtdir=$home/cdt-all/trunk
installdir=$cdtdir/install
user=`cat $home/.cdtname`
export LANG=en_DK.UTF-8

# This update only applies to søren
if cat $home/.cdtname | egrep -v "(søren|soren)" ; then
	echo "This update only applies to Søren's computer"
else
	echo "Updating Søren's computer"

	# Find all files with søren and rename to soren
	cd $cdtdir
	for f in `ls $cdtdir/todo/s*ren ; find $cdtdir/ -print | egrep '[-]s[^-]*ren' | grep -v svn | grep -v malt | grep tag` ; do
		g=`echo $f | sed -e 's/-s[^-]*ren/-soren/g'`
		echo svn mv `ls $f` $g
		svn mv `ls $f` $g
	done

	# Rename cdtname søren to soren
	echo "soren" > $home/.cdtname
	
	# Rename tasks in todo
	svn mv $cdtdir/todo/søren $cdtdir/todo/soren
	cat $cdtdir/todo/s?ren | sed -e 's/-s[^-]*ren/-soren/g' > /tmp/soren
	mv /tmp/soren $cdtdir/todo/soren

	# Commit everything
	sh $cdtdir/tools/dtag-commit

	# Instruct Iørn to restart
	echo "PLEASE restart DTAG now and commit your files"
fi


