#!/usr/bin/env perl

use strict;
use warnings;

my $source_dir = '../source_data/';
my @lang_pairs = qw(da-en da-de da-es da-it);


foreach my $lang_pair (@lang_pairs) {
    print "Language pair: $lang_pair\n";

    my %files_per_author;
    foreach my $atag_file (glob "$source_dir/$lang_pair/*atag") {
        if ( $atag_file =~ /\d\d\d\d-$lang_pair-?(.*?).atag/ ) {
            $files_per_author{$1}++;
            if ($1 ne 'auto') {
                $files_per_author{'(manual)'}++;
            }
        }
        else {
            print STDERR "file doesn't match the pattern: $atag_file\n";
        }
    }

    foreach my $author (sort{$files_per_author{$b}<=>$files_per_author{$a}}
                            keys %files_per_author) {
        print "\t$author\t$files_per_author{$author}\n";
    }

}
