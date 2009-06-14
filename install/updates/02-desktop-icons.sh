#!/bin/bash

home=$HOME
cdtdir=$home/cdt
installdir=$cdtdir/install

# Copy icons to desktop
if ps aux | grep gnome | grep -v grep > /dev/null ; then
        echo "Gnome desktop (eg, Ubuntu): copying Gnome desktop icons"
        cp $installdir/gnome/*.desktop $home/Desktop
fi
if ps aux | grep xfce | grep -v grep ; then
        echo "XFCE desktop (eg, Xubuntu): copying XFCE desktop icons"
fi

