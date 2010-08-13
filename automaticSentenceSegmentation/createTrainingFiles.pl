#!/usr/bin/perl -w

use strict;

# Create training files for sentence-segmenter from conll-files

my $listOfConllFiles = $ARGV[0];
# Get 'local' filename
$listOfConllFiles =~ /.*\/(.*)/;
my $lFilename = $1;

open(TXT, ">$lFilename.txt");

open(FILES, $listOfConllFiles);
while (my $line = <FILES>) {

    chomp($line);

   
   
    open(CONLL, $line);
    my $first = 1;
    while (my $cLine = <CONLL>) {

	chomp($cLine);

	if ($cLine eq "") {
	    print TXT "\n";
	    $first = 1;
	} else {
	    if (!$first) {
		print TXT " ";
	    }
	    my @tokens = split("\t", $cLine);
	    my $word = $tokens[1];
	    print TXT $word;
	    	$first = 0;

	}

	
    }
   
    close(CONLL);

}
 close(TXT);
close(FILES);
