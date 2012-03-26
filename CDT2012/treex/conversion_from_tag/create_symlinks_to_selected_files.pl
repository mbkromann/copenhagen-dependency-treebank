#!/usr/bin/env perl

use strict;
use warnings;

my $outdir = shift @ARGV;

while (<>) {
    chomp;
    my $old_name = "../$_";
    s/.*\///;
    my $new_name = "$outdir/$_";
    print "symlink $old_name --> $new_name\n";
    symlink $old_name, $new_name or die $!;
}

