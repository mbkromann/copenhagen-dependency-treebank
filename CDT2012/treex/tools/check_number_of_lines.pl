#!/usr/bin/env perl
use strict;
use warnings;


my $source_dir = '../source_data/';

foreach my $tagged_file (glob "$source_dir/??/*tagged.tag") {
    my $pattern = $tagged_file;
    $pattern =~ s/tagged/*/;

    my @alternatives = grep {!/tagged|auto|disc/} glob "$pattern";

#    print "$tagged_file\t ALTERN: ".join(' ',@alternatives)."\n";


    if (@alternatives) {

        my %number_of; # number of lines and tokens
        my %tagged_number_of; # number of lines and tokens in -tagged.tag files

        foreach my $filename ($tagged_file, @alternatives) {
            open my $I,$filename or die $!;
            my @lines = <$I>;

            $number_of{lines} = scalar(@lines);
            $number_of{tokens} = scalar(grep {/<W/} @lines);

            if ($filename eq $tagged_file ) {
                $tagged_number_of{lines} = $number_of{lines};
                $tagged_number_of{tokens} = $number_of{tokens};
            }

            else {


                foreach my $type (qw(lines tokens)) {
                    if ($tagged_number_of{$type} != $number_of{$type}) {
                        print "Different number of $type in \t $filename ($number_of{$type} $type, in tagged $tagged_number_of{$type})\n";
                    }
                }

            }
        }
    }
}
