#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp qw( :edit );

my $datadir = '../../data/';

foreach my $filename (glob "$datadir/tag-format/*/*tag") {
    edit_file {
#        s/"<(\/?)s(\/?)>"/"&lt;$1s$2&gt;"/g;
        s/="([^"]*)<([^"]*)"/="$1&lt;$2"/g;
        s/="([^"]*)>([^"]*)"/="$1&gt;$2"/g;
        s/="([^"]*)<([^"]*)"/="$1&lt;$2"/g;
        s/="([^"]*)>([^"]*)"/="$1&gt;$2"/g;
        s/"&"/"&amp;"/g;
    }
        $filename;
}
