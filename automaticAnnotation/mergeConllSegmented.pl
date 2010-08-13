#!/usr/bin/perl -w

use strict;

my $conllFile = $ARGV[0];
my $segmentFile = $ARGV[1];

my $outConllFile = "$conllFile.segmented";

open(CONLL, $conllFile);
open(SEGMENT, $segmentFile);
open(OUTCONLL, ">$outConllFile");

my $sn = 1;
while (my $sentence = <SEGMENT>) {

    chomp $sentence;

    if (!($sentence eq "")) {
	my @tokens = split(" ", $sentence);
	
	my $senLength = scalar(@tokens);
	
	for (my $i=0; $i<$senLength; $i++) {
	    
	    my $conllLine = <CONLL>;
	    chomp $conllLine;
	    my $emptyLine = <CONLL>;
	    
	    my @cTokens = split("\t", $conllLine);
	    my $cWord = $cTokens[1];
	    my $sWord = $tokens[$i];
	    if (!($sWord eq $cWord)) {
		print STDERR "Word mismatch, sen: $sn\t$sWord\t$cWord\n";
	    }
	    $cTokens[0] = $i+1;
	    my $newLine = join("\t", @cTokens);
	    print OUTCONLL "$newLine\n";
	}
	print OUTCONLL "\n";
	}
	
}
close(CONLL);
close(SEGMENT);
close(OUTCONLL);
