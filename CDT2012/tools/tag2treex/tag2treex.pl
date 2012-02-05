#!/usr/bin/env perl

use strict;
use warnings;

use XML::Twig;
#use Treex::Core;

if ( @ARGV==0 ) {
    die "Usage: $0 <list_of_file_to_be_converted_to_treex>";
}

my %files;

foreach my $file (@ARGV) {

    if ( $file !~ /(\d{4})-(da|en|es|it|de|ru)[\.\-]/ ) {
        print "Warning: file name does not match mask: $file";
    }
    else {
        my ($number,$language) = ($1,$2);
        $files{$number}{$language} = $file;
    }
}


foreach my $number (sort keys %files) {
    print $number,"\t",join(" ",sort keys %{$files{$number}}),"\n";

    foreach my $language (sort keys %{$files{$number}}) {

        my $tag_document=XML::Twig->new();    # create the twig
        $tag_document->parsefile( $files{$number}{$language});
        my @sentences = $tag_document->descendants('s');
        print "  $language ".scalar(@sentences)."\n";

    }

}



