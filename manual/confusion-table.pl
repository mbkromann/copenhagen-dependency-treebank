#!/usr/bin/perl

# Open files
my $name= shift(@ARGV);

# Print header
print "\\section{Confusion table: $name}\n\n";
print "\\begin{longtable}{p{30mm}llp{80mm}}\n";
print "\\textbf{R} & \\textbf{N} & \\textbf{A/A\$_U\$/A\$_L\$} & 
	\\textbf{Confusion list} \\\\ \\hline\n";

# Print percentages
sub pct {
	my $x = shift;
	$x =~ s/.$//g;
	return $x;
}

sub rnd {
	return int(0.5 + shift);
}

# Process lines
my ($sumCount, $sumAall, $sumAout, $sumArel) = (0.00001, 0, 0, 0);
my @entries = ();
while (my $line = <>) {
	# Read line
	chomp($line);
	my @fields = split(/\t/, $line);
	my $rel = shift(@fields);
	my $count = shift(@fields);
	my $Aall = pct(shift(@fields));
	my $Aout = pct(shift(@fields));
	my $Arel = pct(shift(@fields));

	# Update weighted sums
	$sumCount += $count;
	$sumAall += $count * $Aall;
	$sumAout += $count * $Aout;
	$sumArel += $count * $Arel;

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
	push @entries, [$Aall, 
		"\\rel{$rel} & $count & " 
			. rnd($Aall) . "/"
			. rnd($Aout) . "/"
			. rnd($Arel) . "\\% & " 
			. "\\small $conflist \\\\\n"];
}

# Print table
print join("", map {$_->[1]} (sort {$b->[0] <=> $a->[0]} @entries));
print "\\hline \\\\\n";
print "TOTAL & "
	. rnd($sumCount) . " & " 
	. rnd($sumAall / $sumCount) . "/"
	. rnd($sumAout / $sumCount) . "/"
	. rnd($sumArel / $sumCount) . "\\% & \\\\\n";
print "\\end{longtable}\n";
