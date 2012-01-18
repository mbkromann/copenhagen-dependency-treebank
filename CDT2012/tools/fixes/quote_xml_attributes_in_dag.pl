#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp qw( :edit );

my $datadir = '../../data/';

foreach my $filename (glob "$datadir/tag-format/*/*tag") {
    edit_file {
        s/ (\w+)=([^"'\s\>]+)/ $1="$2"/g;
    }
        $filename;
}
