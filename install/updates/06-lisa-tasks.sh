#!/bin/bash 

home=/home/cdt
cdtdir=$home/cdt-all/trunk
installdir=$cdtdir/install
user=`cat $home/.cdtname`
export LANG=en_DK.UTF-8

if cat $home/.cdtname | egrep -v "(lisa)" ; then
	echo "This update only applies to Lisa's computer"
else
	echo "Updating Lisa's tasks"
	cd $cdtdir/todo
	grep -v '\[ \] it' lisa > /tmp/x
	mv /tmp/x lisa
fi

