#!/usr/bin/perl -w

use strict;

open(GOLD, $ARGV[0]);
open(SYS, $ARGV[1]);

while (my $gold = <GOLD>) {
    
    chomp $gold;
    my $sys = <SYS>;
    chomp $sys;
    
    
    if ($gold eq "") {
	print "\n";
    }
    else {
	
	my @golda = split("\t", $gold);
	my @sysa = split("\t", $sys);
	
	$golda[6] = $sysa[6];
        $golda[7] = $sysa[7];
	
	
	my $newLine = join("\t", @golda);
	
	print "$newLine\n";
    }
    
}

