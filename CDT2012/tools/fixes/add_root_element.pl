#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp qw( :edit );

my $datadir = '../../data/';

foreach my $filename (glob "$datadir/tag-format/*/*.tag") {
    edit_file {
        if ( not /<tei.2>/ ) {
            s/(.*)/<root>$1<\/root>/sxm;
        }
    }
        $filename;
}
