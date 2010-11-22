#!/usr/bin/perl

# Open files
my $name= shift(@ARGV);

# Print header
print "\\section{Confusion table: $name}\n\n";
print "\\begin{longtable}{lllllp{80mm}}\n";
print "\\textbf{R} & \\textbf{N} & \\textbf{A\$_\\text{all}\$} & \\textbf{A\$_\\text{out}\$} & \\textbf{A\$_\\text{rel}\$} & 
	\\textbf{Confusion list} \\\\ \\hline\n";

# Process lines
my $sum = 0;
my $wsum = 0;
my @entries = ();
while (my $line = <>) {
	# Read line
	chomp($line);
	my @fields = split(/\t/, $line);
	my $rel = shift(@fields);
	my $count = shift(@fields);
	my $Aall = shift(@fields);
	my $Aout = shift(@fields);
	my $Arel = shift(@fields);

	# Process confusion relations
	my @freqs = ();
	my $conflist = "";
	foreach my $pair (@fields) {
		# Find frequency and relation name from FREQ%=REL pair
		my ($cfreq, $crel) = split(/%=/, $pair);

		# Create TeX description of relation
		$conflist .= "\\confuse{" . int($cfreq + 0.5) .  "}{\\rel{$crel}} ";

		# Collect statistics
		# Save frequency of differing relation
		push @freqs, $cfreq if ($crel ne $rel);
	}

	# Compute An scores (self frequency plus frequencies of n other highest-scoring relations)
	#@freqs = sort {$b <=> $a} @freqs;
	#push @freqs, 0, 0;
	#my $A2 = $A + $freqs[0];
	#my $A3 = $A2 + $freqs[1];
	
	# Store result
	push @entries, [$allagree, 
		"\\rel{$rel} & $count & " 
			. int($allagree+0.5) . "\\\\% & " 
			. int($outagree+0.5) . "\\\\% & " 
			. int($relagree+0.5) . "\\\\% & " 
			. "\\small $conflist \\\\\n"];
}

# Print table
print join("", map {$_->[1]} sort {$b->[0] <=> $a->[0]} @entries);
print "\\end{longtable}\n";
