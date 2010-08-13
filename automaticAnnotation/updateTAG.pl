#!/usr/bin/perl -w

# Update tag-file so that out-feture matches in-features.
# Assumes that out-features are empty to begin with.

use strict;
use FileHandle;

my $intagFilename = $ARGV[0];
my $outtagFilename = $ARGV[1];

# Read all lines in tag-file into list
my @tagLines = ();
open(TAGFILE, "$intagFilename");
while (my $line = <TAGFILE>) {

    chomp($line);
    push(@tagLines, $line);
    

}
close(TAGFILE);


my $ln = 0;

for my $tagLine (@tagLines) {


    # Identify head, and line of head
    if ($tagLine =~ /.*in=\"(.*?)\".*/) {
	my $inStr = $1;
	

	if (!($inStr eq "")) {
	    	#print "'$inStr'\n";
	    my @ins = split("\\|", $inStr);
	    for my $in (@ins) {
		
		#print "\t$in\n";
		my @tokens = split(":", $in);
		my $head = $tokens[0];
		my $depRel = $tokens[1];
		
		my $headLineNo = $ln+$head;
		my $headLine = $tagLines[$headLineNo];
		
		# Add dependent to out-feature in head
		$headLine =~ /(.*)out=\"(.*?)\"(.*)/;
		my $before = $1;
		my $inside = $2;
		my $after = $3;
		
	#	print "\t\t$inside\n";
		my $dep = 0-$head;
		if ($inside eq "") {
		    $inside = "$dep:$depRel";
		} else {
		    $inside = "$inside\|$dep:$depRel";
		}
			#	print "\tN\t$inside\n";
		
		my $newLine = $before."out=\"".$inside."\"".$after;
#		print $newLine."\n";
		$tagLines[$headLineNo] = $newLine;
	    }
	}
    }
    $ln++;
}

open(NEWTAGFILE, ">$outtagFilename");
for my $tagLine (@tagLines) {
    
    print NEWTAGFILE "$tagLine\n";
    
}
close(NEWTAGFILE);
