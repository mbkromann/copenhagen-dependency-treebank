#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp;

my $maindir = '../../../';
my @languages = qw(de es it ru);

my %pattern2score = (

    # copied from the handwritten list of files to be preferred, written by Lotte
    '0184-es-soren.tag' => 100,
    '0187-es-jonas.tag' => 100,
    '0307-es-jonas.tag' => 100,
    '0502-es-soren.tag' => 100,
    '0531-es-jonas.tag' => 100,
    '0602-es-jonas.tag' => 100,
    '0620-es-soren.tag' => 100,
    '0781-es-jonas.tag' => 100,
    '0863-es-soren.tag' => 100,

    'lotte' => 10,
    'morten' => 5,

    # Lotte said that file names matching "lotte" should have higher prority than "disc-lotte", and the same holds for Mortnen's
    'disc' => -2,

    # tagged and auto seem to have the same value
    'tagged' => 1,

    # there is usually just one file for ru
    'ru.tag' => 1,
);


my %tag_files;
my %numbers;

foreach my $language (@languages) {
    print STDERR "Processing files from language $language\n";

    foreach my $tag_file (glob "$maindir/$language/????-$language*tag") {
        if ( $tag_file =~ /\/((\d{4})-$language.*)/ ) {
            my ($short_name,$number) = ($1,$2);
            $tag_files{$language}{$number}{$short_name} = 1;
            $numbers{$number} = 1;
        }
        else {
            die "file name does not match required pattern: $tag_file\n";
        }
    }
}

foreach my $number (sort keys %numbers) {

    my $danish_file_pattern = "../../data/tag-format/da/$number*.tag";

    my @da_tag_files = glob $danish_file_pattern;
    print STDERR "Warning: missing Danish file for $danish_file_pattern\n"
        if @da_tag_files == 0;

    print "number: $number\n";
    foreach my $language (@languages) {
        system "mkdir -p ../../data/tag-format/$language";
        my @files = keys %{$tag_files{$language}{$number}||{}};
        my $choice = choose_file(\@files) || '';
        if (defined $choice) {
            my $command = "cp $maindir/$language/$choice ../../data/tag-format/$language";
#            print $command;
            system $command;
        }
        print "  selected for $language: $choice\t".( @files ? (" ignored: ".(join " ",grep{$_ ne $choice}@files)) : '')."\n";
    }

    print "\n";
}




# how to choose a single .tag file from all available
sub choose_file {
    my ($files_rf) = @_;

    my $max_score = 0;
    my $choice;

    foreach my $file (@$files_rf) {
#        print "F$file ";
        my $score;
        foreach my $pattern (keys %pattern2score) {
#            print "$pattern";
            if ($file =~ /$pattern/) {
#                print "match $pattern\n";
                $score += $pattern2score{$pattern};
            }
        }
        if (defined $score and $score > $max_score) {
            $max_score = $score;
            $choice = $file;
        }
    }

    return $choice;

}
