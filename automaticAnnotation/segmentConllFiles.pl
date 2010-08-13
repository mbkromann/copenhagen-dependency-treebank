#!/usr/bin/perl -w

use strict;

# Convert files given in lst-file created by findFiles.pl to CoNNL using DTAG

my $sessionID = $ARGV[0];
my $language = $ARGV[1];


# $sessionID = 0;
# $language = "it";

open (TPFILES, "$sessionID-$language.toParseFiles.lst");
while (my $line = <TPFILES>) {

    chomp $line;
    
    # get 'local' filename
    $line =~ /.*\/(.*)/;
    my $lFilename = $1.".conll";

    system("perl mergeConllSegmented.pl $sessionID-$language.$lFilename $sessionID-$language.$lFilename.txt.segmented");


}
close (TPFILES);
