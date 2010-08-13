#!/usr/bin/perl -w

use strict;

# Segment files using opnnlp and pretrained model

my $listOfConllFiles = $ARGV[0];
my $lang = $ARGV[1];


open(FILES, $listOfConllFiles);
while (my $line = <FILES>) {

    chomp($line);

    # Get 'local' filename
    $line =~ /.*\/(.*)/;
    my $lFilename = "$1.txt";

    system("opennlp SentenceDetector ../automaticSentenceSegmentation/$lang.sentdetect.model < $lFilename > $lFilename.segmented");

    
}

close(FILES);
