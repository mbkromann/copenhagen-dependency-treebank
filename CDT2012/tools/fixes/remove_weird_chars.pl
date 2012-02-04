#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp qw( :edit );
use utf8;

my $regexp_mask = $ARGV[0] || '.';
my $datadir = '../../data/';
use utf8;

foreach my $filename (grep {/$regexp_mask/} glob "$datadir/tag-format/*/*") {

    my $content = File::Slurp::read_file( $filename, { binmode => ':raw' });

    $content =~ s/\xFE\xFF//g;

    if ( $filename =~ /ru/ and $content =~ s/"K..benhavn"/"København"/g ) {

#    if ( $content =~ s/\xF8/\xB8\xC3/g + 0 ) { #\xB8\xC3
        binmode STDOUT, ':raw';
        print $content;
        print STDERR "Storing changes in file $filename \n";
#        open my $OUT, ">",$filename;
#        print $OUT  join '', map {"<$_"} @new_segments;
#        close $OUT;
    }

}
