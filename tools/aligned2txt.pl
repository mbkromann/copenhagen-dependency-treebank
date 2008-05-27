#!/usr/bin/perl

sub aligned2txt {
	my $in = shift;
	my $out = shift;

	# Open input file
	open(IN, "<$in");
	open(OTXT, ">$out.txt");
	open(OREF, ">$out.ref");

	# Read lines in input
	my $linepos = 0;
	while (my $line = <IN>) {
		++$linepos;
		my $w = 0;
		foreach my $word (split(/ /, $line)) {
			chomp($word);
			print OTXT "$word\n";
			print OREF "$linepos:" . $w++ . ":$word\n";
		}
	}

	# Close files
	close(IN);
	close(OTXT);
	close(OREF);
}

aligned2txt(@ARGV);

