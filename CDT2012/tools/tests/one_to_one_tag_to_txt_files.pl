#!/usr/bin/perl

use strict;
use warnings;

my $datadir = '../../data/';

my %files;

foreach my $extension (qw(txt tag)) {
    foreach my $filename ("$datadir/tag-format/??/*$extension") {
        $files{$extension}{$filename}++;
    }
}

if ( (keys %{$files{txt}}) != (keys %{$files{tag}})) {
    print STDERR "The number of .txt and .tag files differ\n";
}

foreach my $txtfile (keys %{$files{txt}}) {
    my $tagfile = $txtfile;
    $tagfile =~ s/txt$/tag/;
    if (not $files{tag}{$tagfile}) {
        print STDERR "Missing .tag counterpart for $txtfile\n";
    }
}
