#!/usr/bin/perl
use strict;
use warnings;
use CheckAlignment;

my ($source_dir,$out_dir) = @ARGV;

if (not -d $source_dir) {
    die "Directory with source files is expected as the first argument, but got $source_dir";
}

my @lang_pairs = qw(da-en da-de da-es da-it);

my %atagpattern2score = (

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

my %tagpattern2score = (

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


my %atag_files;
my %numbers;

foreach my $lang_pair (@lang_pairs) {
    print STDERR "Processing files from language pair $lang_pair\n";

  FILE:
    foreach my $tag_file (grep {!/auto/} glob "$source_dir/$lang_pair/????-$lang_pair*tag") {

        next FILE if $tag_file =~ /0863-da-it-morten/; # files ignored because of wrong encoding

        if ( $tag_file =~ /(.+(\d{4})-$lang_pair.*)/ ) {
            my ($short_name,$number) = ($1,$2);
            $atag_files{$lang_pair}{$number}{$short_name} = 1;
            $numbers{$number} = 1;
        }
        else {
            die "file name does not match required pattern: $tag_file\n";
        }
    }
}

foreach my $number (sort keys %numbers) {

    print "number=$number\n";

    my $danish_file = "$source_dir/da/$number-da.tag";
    if (-f $danish_file) {
        print "    SELECTED tag file\t$danish_file\n";
    }
    else {
        die "missing Danish file $danish_file\n";
    }

    foreach my $lang_pair (@lang_pairs) {
        print "  language_pair=$lang_pair\n";

        my @atag_files = sort_atag_files( keys %{ $atag_files{$lang_pair}{$number} || {} } );

        if ( @atag_files == 0 ) { # no alignment available -> choose an unaligned file
            my ($language) = reverse split /-/,$lang_pair;
            choose_unaligned_tag($language,$number);
        }

        else {

            my $atag_winner = $atag_files[0];

            foreach my $atag_file (@atag_files) {
                if ($atag_file eq $atag_winner) {
                    print "    SELECTED atag";
                }
                else {
                    print "    ignored atag";
                }
                print "\t",$atag_file,"\n";
            }

            my $pattern_for_b_files = $atag_winner;
            $pattern_for_b_files =~ s/(da-..-)([^-.]+)/$1*/;
            $pattern_for_b_files =~ s/da-//g;
            $pattern_for_b_files =~ s/\.atag/.tag/;

            my @guessed_b_tag_files =  grep {!/0863-it-morten/} # ignored because of wrong encoding
                grep {!/auto/} glob $pattern_for_b_files;

            if (@guessed_b_tag_files == 0) {
                print STDERR "Error: no available .tag file matching the expected pattern\n";
            }

            else {
                my %good_alignments;
                my %bad_alignments;
                my %total_score;
                foreach my $file (@guessed_b_tag_files) {
                    ($good_alignments{$file},$bad_alignments{$file}) = CheckAlignment::check($atag_winner,$file);
                    $total_score{$file} = $good_alignments{$file} + tag_file_score($file)/1000;
                }

                my @sorted_candidates = sort {$total_score{$b}<=>$total_score{$a}} keys %total_score;
                foreach my $file (@sorted_candidates) {
                    if ($file eq $sorted_candidates[0]) {
                        print "      SELECTED tag file ";
                    }
                    else {
                        print "      ignored tag file ";
                    }
                    print "(good:bad align=$good_alignments{$file}:$bad_alignments{$file}):\t$file\n"

                }

                if ($good_alignments{$sorted_candidates[0]} < $bad_alignments{$sorted_candidates[0]}) {
                    print STDERR "Even the best tag file does not fit well the atag file\n";
                }
            }
        }
    }
    print "\n";
}


# ------------------------- scoring a-tag files ----------------------



# how to choose a single .tag file from all available
sub sort_atag_files {
    my @files = @_;

    my %score;

    foreach my $file (@files) {
        $score{$file} = 0;
        foreach my $pattern (keys %atagpattern2score) {
            if ($file =~ /$pattern/) {
                $score{$file} += $atagpattern2score{$pattern};
            }
        }
    }

    @files = sort { $score{$b} <=> $score{$a} } @files;

    if (@files > 1 and $score{$files[0]} == $score{$files[1]}) {
        print STDERR "WARNING: same score:  $files[0] ($score{$files[0]}) $files[1]  ($score{$files[1]})\n";
    }

    return @files;
}

# ------------------------- scoring tag files ----------------------


sub tag_file_score {
    my ($file) = @_;

    my $score = 0;
    foreach my $pattern (keys %tagpattern2score) {
        if ($file =~ /$pattern/) {
            $score += $tagpattern2score{$pattern};
        }
    }
    return $score;

}


# --------------------------

sub choose_unaligned_tag {
    my ($language,$number) = @_;

    my @tag_candidates = grep {!/auto/} grep {!/0863-it-morten/} glob "$source_dir/$language/$number*.tag";
    if (not @tag_candidates) {
        print "      no tag file found for $language $number\n";
        return undef;
    }

    else {
        my %score;

        foreach my $file (@tag_candidates) {
            $score{$file} = tag_file_score($file);
        }

        my @sorted_candidates = sort {$score{$b}<=>$score{$a}} @tag_candidates;

#        print "Unaligned: Chosen unaligned file: $sorted_candidates[0]\n";
        foreach my $i (0..$#sorted_candidates) {
            if ($i == 0) {
                print "      SELECTED tag (unaligned):";
            }
            else {
                print "      ignored unaligned tag (unaligned):";
            }
            print "\t".$sorted_candidates[$i]."\n";
        }


        return $sorted_candidates[0];
    }
}
