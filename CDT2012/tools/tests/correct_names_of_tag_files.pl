#!/usr/bin/perl

use strict;
use warnings;

my $datadir = '../../data/';

foreach my $filename (glob "$datadir/tag-format/??/*") {
    my ($shortname,$language) = reverse split '/', $filename;
    if ($shortname !~ /^\d{4}-$language.(tag|txt)$/) {
        print STDERR "File name does not match the required pattern: $filename\n";
    }

}
