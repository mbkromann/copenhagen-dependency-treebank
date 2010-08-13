#!/usr/bin/perl

open(GOLD, $ARGV[0]);
open(SYS, $ARGV[1]);

while ($gold = <GOLD>) {

    chomp $gold;
$sys = <SYS>;
    chomp $sys;


    if ($gold eq "") {
	print "\n";
    }else  {
    
    @golda = split("\t", $gold);
    @sysa = split("\t", $sys);

    $golda[6] = $sysa[6];
        $golda[7] = $sysa[7];


    $newLine = join("\t", @golda);

    print "$newLine\n";
    }

}

