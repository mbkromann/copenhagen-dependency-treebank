#!/usr/bin/perl -w

# Calculate accuracies for different labels for use in pruning

use strict;
use FileHandle;

my $goldFile = $ARGV[0];
my $sysFile = $ARGV[1];

system("perl merge.pl $goldFile $sysFile > $sysFile.merged");


my %total = ();
my %correct = ();

open (GOLD, $goldFile);
open (SYS, "$sysFile.merged");

my $total = 0;
while (my $goldLine = <GOLD>) {

    my $sysLine = <SYS>;
    chomp($goldLine);
    chomp($sysLine);

    if (!($goldLine eq "")) {
	my @goldTokens = split("\t", $goldLine);
	my @sysTokens = split("\t", $sysLine);
	
	my $goldHead = $goldTokens[6];
	my $sysHead = $sysTokens[6];
	
	my $goldDeprel = $goldTokens[7];
	my $sysDeprel = $sysTokens[7];
	
	if (($goldDeprel eq $sysDeprel) && ($goldHead == $sysHead)) {
	    
	    $correct{$sysDeprel}++;
	}
	$total{$sysDeprel}++;
	$total++;
    }
}

close(GOLD);
close(SYS);

print "depRel\tfreq\taccuracy\n";
for my $depRel (keys %total) {

    my $t = $total{$depRel};
    my $c = $correct{$depRel};



    my $acc = $c/$t;
    my $freq = $t/$total;

    print "$depRel\t$freq\t$acc\n";
    

}
