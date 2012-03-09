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

    if ( $file !~ /(\d{4})-((da-)?(da|en|es|it|de|ru))[\.\-]/ ) {
        print STDERR "Warning: file name does not match mask: $file";
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

    foreach my $language (sort grep {/^..$/} keys %{$files{$number}}) {

        open my $TAG,"<:utf8", $files{$number}{$language};
        my $file_content;
        my $line_number = -1; # root element line seems not to be counted
        while (<$TAG>) {
            $line_number++;
            s/<W /<W linenumber="$line_number" /;
            $file_content .= $_;
        }

        my $tag_document=XML::Twig->new();    # create the twig
        $tag_document->parse( $file_content );

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


    foreach my $language_pair (sort grep {/-/} keys %{$files{$number}}) {

        my ($danish,$second_language) = split /-/,$language_pair;

        $bundle->wild->{$second_language} = [];

        my $atag_document=XML::Twig->new();
        $atag_document->parsefile( $files{$number}{$language_pair} );

        foreach my $align_element ($atag_document->descendants('align')) {
            my %attr_hash = ();
            foreach my $attr_name (keys %{$align_element->{'att'}||{}}) {
                $attr_hash{$attr_name} = $align_element->{'att'}->{$attr_name};
            }
            push @{$bundle->wild->{$second_language}}, \%attr_hash;
        }
    }

    $doc->save('test.treex.gz');
}




