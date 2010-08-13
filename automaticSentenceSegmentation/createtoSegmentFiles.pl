#!/usr/bin/perl -w

use strict;

# Create files to sentence-segmenter from conll-files

my $listOfConllFiles = $ARGV[0];



open(FILES, $listOfConllFiles);
while (my $line = <FILES>) {

    chomp($line);

    # Get 'local' filename
    $line =~ /.*\/(.*)/;
    my $lFilename = $1;
    open(TXT, ">$lFilename.txt");
   

    open(CONLL, $line);
    my $first = 1;
    while (my $cLine = <CONLL>) {

	chomp($cLine);

	
	if (!($cLine eq "")) {
	    if (!$first) {
		print TXT " ";
	    }
	    my @tokens = split("\t", $cLine);
	    my $word = $tokens[1];
	    print TXT $word;
	    $first = 0;
	}
	
	
	
    }
    close(TXT);    
    close(CONLL);
    
}

close(FILES);
