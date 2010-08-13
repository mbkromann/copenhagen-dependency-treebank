#!/usr/bin/perl -w

use strict;
use Cwd 'abs_path';


# Create list of conll-files to use with sentence-segmenter

my $sessionID = $ARGV[0];
my $language = $ARGV[1];

# $sessionID = 0;
# $language = "it";

open (FILES, "$sessionID-$language.trainingFiles.lst");
open (ABSFILES, ">$sessionID-$language.trainingFiles.lst.abs");
while (my $line = <FILES>) {

    chomp $line;
    
    # get 'local' filename + conll
    $line =~ /.*\/(.*)/;
    my $lFilename = "$sessionID-$language.$1.conll";
    my $absFilename = abs_path($lFilename);
    print ABSFILES "$absFilename\n";
}
close(FILES);
close(ABSFILES);

open (FILES, "$sessionID-$language.toParseFiles.lst");
open (ABSFILES, ">$sessionID-$language.toParseFiles.lst.abs");
while (my $line = <FILES>) {

    chomp $line;
    
    # get 'local' filename + conll
    $line =~ /.*\/(.*)/;
    my $lFilename = "$sessionID-$language.$1.conll";
    my $absFilename = abs_path($lFilename);
    print ABSFILES "$absFilename\n";
}
close(FILES);
close(ABSFILES);
