#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp qw( :edit );

my $regexp_mask = $ARGV[0] || '.';
my $datadir = '../../data/';

foreach my $filename (grep {/$regexp_mask/} glob "$datadir/tag-format/*/*") {
    edit_file {
        s/(<availability status="restricted">)<p>/$1/g;
        s/<(addrline|language)>//g;
        s/(<catRef target="[^"]*")>/$1\/>/g;
        s/(<title>.+)<title>/$1<\/title>/g;
    }
        $filename;
}
