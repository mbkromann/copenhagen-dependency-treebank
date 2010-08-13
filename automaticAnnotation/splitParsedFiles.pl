#!/usr/bin/perl -w

use strict;

# Split parsed files into equivalents to the original files

my $sessionID = $ARGV[0];
my $language = $ARGV[1];


# $sessionID = 0;
# $language = "it";

open (PARSE, "$sessionID-$language.out.conll.pruned");
open (FILES, "$sessionID-$language.toParseFiles.lst");

while (my $line = <FILES>) {
    chomp $line;
    
    # get 'local' filename + conll
    $line =~ /.*\/(.*)/;
    my $lFilename = "$sessionID-$language.$1.conll.segmented.cleaned";
    
    open(NEWCONLL, ">$lFilename.out"); 
    open(CONLL, "$lFilename");
    
    while (my $cLine = <CONLL>) {
	
	my $pLine = <PARSE>;
	
	print NEWCONLL $pLine;

    }
    close(CONLL);
    close(NEWCONLL);
}
close(FILES);
close(PARSE);
