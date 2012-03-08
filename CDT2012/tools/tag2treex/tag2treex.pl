#!/usr/bin/env perl

use strict;
use warnings;

use XML::Twig;
use Treex::Core;

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

    my $doc = Treex::Core::Document->new();
    my $bundle = $doc->create_bundle();

    foreach my $language (sort keys %{$files{$number}}) {
        my $tag_document=XML::Twig->new();    # create the twig
        $tag_document->parsefile( $files{$number}{$language});
        my @sentences = $tag_document->descendants('s');
        print "  $language ".scalar(@sentences)."\n";

        my $zone = $bundle->create_zone($language);
        my $atree = $zone->create_atree;
        my $ord = 0;

        my %sent_number;
        my %para_number;

        my $para_counter = 0;
        foreach my $para ($tag_document->descendants('p')) {
            $para_counter++;
            foreach my $tag_token ($para->descendants('W')) {
                $para_number{$tag_token} = $para_counter;
            }
        }

        my $sent_counter = 0;
        foreach my $sent ($tag_document->descendants('s')) {
            $sent_counter++;
            foreach my $tag_token ($sent->descendants('W')) {
                $sent_number{$tag_token} = $sent_counter;
            }
        }


        foreach my $tag_token ($tag_document->descendants('W')) {
            $ord++;
            my $anode = $atree->create_child(
                {
                    form => $tag_token->text,
                    ord => $ord,
                }
            );
            foreach my $attr_name (keys %{$tag_token->{'att'}||{}}) {
                $anode->wild->{$attr_name} = $tag_token->{'att'}->{$attr_name};
            }
            $anode->wild->{para_number} = $para_number{$tag_token} || 0;
            $anode->wild->{sent_number} = $sent_number{$tag_token} || 0;
        }
    }

    $doc->save('test.treex.gz');
}




