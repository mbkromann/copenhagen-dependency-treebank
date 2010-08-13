#!/usr/bin/perl -w

use strict;

# Merge conll-files for use with parser

my $sessionID = $ARGV[0];
my $language = $ARGV[1];


$sessionID = 0;
$language = "it";

open (TRAIN, ">$sessionID-$language.train.conll");
open (FILES, "$sessionID-$language.trainingFiles.lst");
while (my $line = <FILES>) {

    chomp $line;
    
    # get 'local' filename + conll
    $line =~ /.*\/(.*)/;
    my $lFilename = "$sessionID-$language.$1.conll.cleaned";
    
    open(CONLL, "$lFilename");


    while (my $cLine = <CONLL>) {
	
	print TRAIN $cLine;
    }
    close(CONLL);
}
close(FILES);
close(TRAIN);

open (PARSE, ">$sessionID-$language.parse.conll");
open (FILES, "$sessionID-$language.toParseFiles.lst");
while (my $line = <FILES>) {

    chomp $line;
    
    # get 'local' filename + conll
    $line =~ /.*\/(.*)/;
    my $lFilename = "$sessionID-$language.$1.conll.segmented.cleaned";
    
    open(CONLL, "$lFilename");

    
    while (my $cLine = <CONLL>) {
	
	print PARSE $cLine;
    }
    close(CONLL);
}
close(FILES);
close(PARSE);
