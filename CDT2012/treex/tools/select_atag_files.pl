#!/usr/bin/perl

use strict;
use warnings;

my $source_dir = '../source_data/';
my @lang_pairs = qw(da-en da-de da-es da-it);

use File::Slurp;

my %pattern2score = (

    'lisa' => 10,
    'lotte' => 9,

    'morten' => 8,
    'iorn' => 7,

#    # Lotte said that file names matching "lotte" should have higher prority than "disc-lotte", and the same holds for Mortnen's
#    'disc' => -2,

    'soren' => 2,
    'jonas' => 2,
    'henrik' => 1.5,

    # tagged and auto seem to have the same value
    'tagged' => 1,
#    'auto' => -100, # auto files completely excluded, no annotation, wrong xml

);


my %tag_files;
my %numbers;

foreach my $lang_pair (@lang_pairs) {
    print STDERR "Processing files from language pair $lang_pair\n";

    foreach my $tag_file (grep {!/auto/} glob "$source_dir/$lang_pair/????-$lang_pair*tag") {
        if ( $tag_file =~ /\/((\d{4})-$lang_pair.*)/ ) {
            my ($short_name,$number) = ($1,$2);
            $tag_files{$lang_pair}{$number}{$short_name} = 1;
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
    foreach my $lang_pair (@lang_pairs) {
#        system "mkdir -p ../../data/tag-format/$lang_pair";
        my @files = keys %{$tag_files{$lang_pair}{$number}||{}};
        @files = sort_files(\@files);

        my $choice = shift @files || '';
#        if (defined $choice ){#and (-s "$source_dir/$lang_pair/$choice" != 151 ) { # .atag files with no annotation and wrong xml structure
#            my $command = "cp $source_dir/$lang_pair/$choice ../../data/tag-format/$lang_pair";
#            print $command;
#            system $command;
#        }
        print "  selected for $lang_pair: $choice\t".( @files ? (" ignored: ".(join " ",grep{$_ ne $choice}@files)) : '')."\n";

        if ($choice) {
            my $atag_filename = "$source_dir/$lang_pair/$choice";
            my $atag_content = File::Slurp::read_file( $atag_filename ) or die $!;
            my %tag_file;

            foreach my $direction (qw(a b)) {

                if ($atag_content =~ /<alignFile key="$direction" href="(.+)" sign="_input"\/>/) {
                    my $tagfile = "$source_dir/$lang_pair/$1";

                    if (not -f $tagfile) {
                        print STDERR "Warning: can't find $tagfile\n";
                    }

                    elsif ($tagfile =~ /(.+)tagged(.+)/) {
                        my @other_files = map {s/.+\///;$_} grep {$_!~/tagged|auto/} glob "$1*$2";
                        if (@other_files) {
                            print  "     Warning:  manually annotated files exist besides referenced tagged file: ".
                                join(' ', @other_files)."\n";
                        }
                    }

                    elsif ($tagfile =~ /[^-]{3,}.tag/) {
                        print STDERR "Other than tagged filed referred to from $tagfile : $choice\n";
                    }


                }
                else {
                    print STDERR "Warning: can't find referenced tag file in $choice, direction $direction\n";
                }
            }



            my $pattern_for_b_files = $atag_filename;
            $pattern_for_b_files =~ s/(da-..-)([^-.]+)/$1*/;
            $pattern_for_b_files =~ s/da-//g;
            $pattern_for_b_files =~ s/\.atag/.tag/;

            my @guessed_b_tag_files =  grep {!/tagged|auto/} glob $pattern_for_b_files;

            print STDERR "$pattern_for_b_files: ".(join ' ',@guessed_b_tag_files)."\n";
            if (@guessed_b_tag_files == 0) {
                print STDERR "NONE\n";
            }


#            my $guessed_b_tag_file = $atag_filename;
#            $guessed_b_tag_file =~ s/da-//g;
#            $guessed_b_tag_file =~ s/\.atag/.tag/;
#            if (not -f $guessed_b_tag_file) {
#                print STDERR "Guessed b-file needed for $atag_filename doesn't exist: $guessed_b_tag_file\n";
#            }
#            else {
#                print STDERR "OK, guessed b-files exists: $guessed_b_tag_file\n";
#            }

        }


    }
    print "\n";
}




# how to choose a single .tag file from all available
sub sort_files {
    my ($files_rf) = @_;

    my $max_score = 0;
    my $choice;

    my %score;

    foreach my $file (@$files_rf) {
#        print "F$file ";
        foreach my $pattern (keys %pattern2score) {
#            print "$pattern";
            if ($file =~ /$pattern/) {
#                print "match $pattern\n";
                $score{$file} += $pattern2score{$pattern};
            }
        }
    }


    my @files = sort {$score{$b} <=> $score{$a}} @$files_rf;

    if (@files > 1 and $score{$files[0]} == $score{$files[1]}) {
        print STDERR "WARNING: same score:  $files[0] $files[1]\n";
    }

    return @files;

}
