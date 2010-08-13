#!/usr/bin/perl -w

use strict;
use FileHandle;

my $conllFilename = $ARGV[0];
my $tagFilename = $ARGV[1];
my $outTagFilename = $ARGV[2];

# Read all lines in tag-file into list
my @tagLines = ();
open(TAGFILE, "$tagFilename");
while (my $line = <TAGFILE>) {

    chomp($line);
    push(@tagLines, $line);
    

}
close(TAGFILE);


# Open conll-file
my $conllFile = FileHandle->new;
$conllFile->open("$conllFilename");

my @conllSentence = ();

# Run through conll-file and update tag-file with heads and relations
while ((my $res = getNextSen($conllFile, \@conllSentence)) == 1) {


    for my $s (@conllSentence) {


	my $in = "";

	# Get tag-line number
	my @tokens = split("\t", $s);
	my $featToken = $tokens[5];

	$featToken =~ /.*line=(\d+).*/;
	my $ln = $1;

	# Get corresponding tag-line
	my $tagLine = $tagLines[$ln];

	# Split tag-line into before, after and inside 'in="   "'
#	print "$tagLine\n";
	$tagLine =~ /(.*)in=\".*?\"(.*)/;
	my $before = $1;
	my $after = $2;
#	print "\t$before\n";
#	print "\t$after\n";

	# Get tag-line number of head
	my $head = $tokens[6];
	if ($head != 0) {
	my $headLine = $conllSentence[$head-1];
	
	my @headTokens = split("\t", $headLine);
	my $headFeatToken = $headTokens[5];
	$headFeatToken =~ /.*line=(\d+).*/;
	my $headLn = $1;

	# Relative posistion
	my $relPos = $headLn - $ln;

	# deprel
	my $delRel = $tokens[7];

	# Create new tagline
	$in = "$relPos:$delRel";
	}
	my $newLine = $before."in=\"$in\"".$after;

	# Update line
	$tagLines[$ln] = $newLine;


    }
    @conllSentence = ();
}
$conllFile->close();


# Print new tag-file

open(NEWTAG, ">$outTagFilename");
for my $l (@tagLines) {

    print NEWTAG "$l\n";
}
close(NEWTAG);


# Subroutine to read lines from one conll-sentence
sub getNextSen {

    my $cFile = shift;
    my $conllSentenceRef = shift;
    my $readLines = 0;

    while (my $line = <$cFile>) {
	
	chomp $line;
	if ($line eq "") {

	    last;
	}
	push(@$conllSentenceRef, $line);

	$readLines = 1;
    }

    return $readLines;
}



