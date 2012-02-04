#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp qw( :edit );

my $regexp_mask = $ARGV[0] || '.';
my $datadir = '../../data/';

foreach my $filename (grep {/$regexp_mask/} glob "$datadir/tag-format/*/*tag") {
    edit_file_lines sub {
        s/(="[^"]*?)<([^"]*?")/$1&lt;$2/g;
        s/(="[^"]*?)>([^"]*?")/$1&gt;$2/g;

        s/(="[^"]*?)<([^"]*?")/$1&lt;$2/g;
        s/(="[^"]*?)>([^"]*?")/$1&gt;$2/g;

        s/"&"/"&amp;"/g;
        s/>&</>&amp;</g;
    },
        $filename;
}
