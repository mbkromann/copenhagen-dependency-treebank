#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp qw( :edit );

my $datadir = '../../data/';

foreach my $filename (glob "$datadir/tag-format/*/*") {
    edit_file {
        s/&3a;/:/g;
        s/&7c;/|/g;
        s/&amp;quot;/&quot;/g;
    }
        $filename;
}
