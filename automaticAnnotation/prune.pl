#!/usr/bin/perl -w

use strict;

my $statsFile = $ARGV[0];
my $conllFile = $ARGV[1];
my $cutOff = $ARGV[2];

open(STAT, $statsFile);

my %accuracies = ();
# First line in just info
my $line = <STAT>;
while ($line = <STAT>) {

    chomp $line;
    my @tokens = split("\t", $line);

    $accuracies{$tokens[0]} = $tokens[2];
}

close(STAT);

open (CONLL, $conllFile);

while ($line = <CONLL>) {
    
    chomp $line;

    if ($line eq "") {
	print "\n";
    } else {
	my @tokens = split("\t", $line);
	my $depRel = $tokens[7];
	my $acc = $accuracies{$depRel};
	if ($acc < $cutOff) {
	    $tokens[6]=-1;
	    $tokens[7]="<PRUNED>";
	    my $newLine = join("\t", @tokens);
	    print "$newLine\n";
	} else {
	    print "$line\n";
	}
    }
}

    




