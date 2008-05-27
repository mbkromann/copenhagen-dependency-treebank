#!/usr/bin/perl

my $debug = 1;

sub diff2align {
	my $diff = shift;
	my $ref1 = shift;
	my $ref2 = shift;

	# Open file and reset counters
	open(DIFF, "<$diff");
	my ($i, $j) = (1, 1);
	my $hash = {};

	# Process diff file
	while (my $line = <DIFF>) {
		print DEBUG "# $line\n" if ($debug);
		if ($line =~ /^([0-9]+)a([0-9]+)(,([0-9]+))?$/) {
			# Make 1-1 alignments up to this point
			for (; $i <= $1; ++$i && ++$j) {
				$hash->{red($ref1->[$i])} .= $ref2->[$j] . " ";
				print DEBUG "$i=$j\n" if ($debug);
				print DEBUG "  " . $ref1->[$i] . " = " . $ref2->[$j] . "\n" 
					if ($debug);
			}

			# Set $i and $j
			$j = ($3 ? $4 : $2) + 1;
		} elsif ($line =~ /^([0-9]+)(,([0-9]+))?d([0-9]+)$/) {
			# Make 1-1 alignments up to this point
			for (; $i < $1; ++$i && ++$j) {
				$hash->{red($ref1->[$i])} .= $ref2->[$j] . " ";
				print DEBUG "$i=$j\n" if ($debug);
				print DEBUG "  " . $ref1->[$i] . " = " . $ref2->[$j] . "\n" 
					if ($debug);
			}

			# Set $i and $j
			$i = ($2 ? $3 : $1) + 1;
		} elsif ($line =~ /^([0-9]+)(,([0-9]+))?c([0-9]+)(,([0-9]+))?$/) {
			# Make 1-1 alignments up to this point
			for (; $i < $1; ++$i && ++$j) {
				$hash->{red($ref1->[$i])} .= $ref2->[$j] . " ";
				print DEBUG "$i=$j\n" if ($debug);
				print DEBUG "  " . $ref1->[$i] . " = " . $ref2->[$j] . "\n" 
					if ($debug);
			}

			# Make m-n alignment
			my $jstr = "";
			for ( ; $j <= ($5 ? $6 : $4); ++$j) {
				$jstr .= $ref2->[$j] . " ";
			}
			for ( ; $i <= ($2 ? $3 : $1); ++$i) {
				$hash->{red($ref1->[$i])} .= $jstr;
				print DEBUG "  " . $ref1->[$i] . " = " . $jstr . "\n"
					if ($debug);
			}
		} 
	}

	# Close and return hash
	close(DIFF);
	return $hash;
}

sub red {
	my $str = shift;
	my ($a, $b) = split(/:/, $str);
	return "$a:$b";
}

sub readref {
	my $ref = shift;

	# Read ref-file
	open(IN, "<$ref");
	my $lines = [undef,];
	while (my $line = <IN>) {
		chomp($line);
		push @$lines, $line;
	}
	close(IN);

	# Return array
	return $lines;
}

sub giza2dtag {
	my ($gizafile, $path, $dkhash, $enhash, $dkpath, $enpath, $slang, $tlang) = @_;

	# Open GIZA file
	open(GIZA, "<$gizafile");
	my $edgecount = 0;
	my $ignorecount = 0;

	# Process GIZA file
	my $lineno = 0;
	my $components = {};
	while (my $line = <GIZA>) {
		++$lineno;
		chomp($line);
		# print "GIZA[$lineno]: $line\n";
		foreach my $pair (split(/ /, $line)) {
			my ($idk, $ien) = split(/-/, $pair);
			merge_components($components, 
				lookup("a", $dkhash, "$lineno:$idk"), 
				lookup("b", $enhash, "$lineno:$ien"));
		}
	}

	# Find all nodes in $dkhash and $enhash
	my $nodes = {};
	foreach my $n (values(%$dkhash)) {
		map {$_ =~ /^([0-9]+):([0-9]+):(.*)$/;
			$nodes->{"$1:a$2:$3"} = 1} split(/ /, $n);
	}
	foreach my $n (values(%$enhash)) {
		map {$_ =~ /^([0-9]+):([0-9]+):(.*)$/;
			$nodes->{"$1:b$2:$3"} = 1} split(/ /, $n);
	}

	# Print all deleted nodes
	foreach my $n (keys(%$nodes)) {
		$components->{$n} = [$n] if (! $components->{$n});
	}

	# Print ATAG file
	my ($id, $idold) = ("", "");
	my $donehash = {};
	# print "KEYS IN HASH: " . scalar(keys(%$components)) . "\n";
	# foreach my $key (keys(%$components)) {
	foreach my $key (sort
			{	$a =~ /^([0-9]+):([ab])([0-9]+):(.*)$/;
				my ($a1, $a2, $a3, $a4) = ($1, $2, $3, $4);
				$b =~ /^([0-9]+):([ab])([0-9]+):(.*)$/;
				my ($b1, $b2, $b3, $b4) = ($1, $2, $3, $4);
				("$a1$a2" cmp "$b1$b2")
					|| ($a3 <=> $b3); }
			sort(keys(%$components))) {
		# print "$key\n";
		my $comp = $components->{$key};
		if (! $donehash->{$comp}) {
			# Mark $comp as done
			$donehash->{$comp} = 1;
			#print DEBUG "ATAG: " . join(" ", @$comp) . "\n"
			#	if ($debug > 1);

			# Find file id
			$id = [split(/:/, $comp->[0])]->[0];
			if ($id ne $idold) {
				# Close previous file
				if ($idold) {
					print ATAG "</DTAGalign>\n";
					close(ATAG);
				}

				# Open new file
				print "Creating $path/$id-$slang-$tlang-auto.atag\n";
				open(ATAG, ">$path/$id-$slang-$tlang-auto.atag");
				print ATAG "<DTAGalign>\n";
				print ATAG "<alignFile key=\"a\" href=\"$dkpath/$id-$slang.tag\" sign=\"_input\"/>\n";
				print ATAG "<alignFile key=\"b\" href=\"$enpath/$id-$tlang-auto.tag\" sign=\"_input\"/>\n";
				$idold = $id;
			}

			# Print alignment edge
			my @mnodes = map {$_ =~ /^([0-9]+):(.*)$/; $2} @$comp;
			my @anodes = grep {substr($_, 0, 1) eq "a"} @mnodes;
			my @bnodes = grep {substr($_, 0, 1) eq "b"} @mnodes;

			# Look for zero edges
			@anodes = @bnodes if (! @anodes);
			@bnodes = @anodes if (! @bnodes);

			# Remove punctuation nodes
			@anodes = grep {$_ !~ /^[ab][0-9]+:[ ,;:!?\/\.'"\(\)*-]+$/} @anodes;
			@bnodes = grep {$_ !~ /^[ab][0-9]+:[ ,;:!?\/\.'"\(\)*-]+$/} @bnodes;

			# Print
			my $aedge = "<align"
				. " out=\"" . join("+", 
						map {$_ =~ /^([ab][0-9]+):/; $1} @anodes) . "\""
				. " type=\"\""
				. " in=\"" . join("+", 
						map {$_ =~ /^([ab][0-9]+):/; $1} @bnodes) . "\""
				. " creator=\"-101\""
				. " outsign=\"" . join(" ",
						map {$_ =~ /^([ab][0-9]+):(.*)$/; 
							my $s = $2; 
							$s =~ s/"/\&quot;/g;
							$s} @anodes) . "\""
				. " insign=\"" . join(" ",
						map {$_ =~ /^([ab][0-9]+):(.*)$/; 
							my $s = $2; 
							$s =~ s/"/\&quot;/g;
							$s} @bnodes) . "\""
				. "/>\n";
			++$edgecount;
			if ($aedge =~ /(\+.*){4,}/) {
				++$ignorecount;
				print "ignoring alignment edge with more than 6 nodes: $aedge\n";
			} else {
				print ATAG $aedge;
			}
		}
	}

	# Close ATAG and GIZA files
	print ATAG "</DTAGalign>\n";
	close(ATAG);
	close(GIZA);

	# Debugging
	print "ignored $ignorecount out of $edgecount edges because of size limit\n";
}

sub lookup {
	my ($key, $hash, $id) = @_;
	return map {
		$_ =~ /^([0-9]+):([0-9]+):(.*)$/;
		"$1:$key$2:$3"} 
		split(/ /, $hash->{$id});
}

sub merge_components {
	my $components = shift;

	# Find all entries in components
 	my $merged = {};
	foreach my $key (@_) {
		my $keycomp = $components->{$key} || [$key];
		foreach my $subkey (@$keycomp) {
			$merged->{$subkey} = 1;
		}
	}

	# Merge components
	my $newcomponent = [sort(keys(%$merged))];
	foreach my $key (@$newcomponent) {
		$components->{$key} = $newcomponent;
	}

	# print "MERGE: " . join(" ", @$newcomponent) . "\n";
}

# MAIN
my ($base, $slang, $tlang) = @ARGV;
my $salign="$base.align.$slang";
my $talign="$base.align.$tlang";
my $stag="$base.tag.$slang";
my $ttag="$base.tag.$tlang";
my $diag="$base.grow-diag-final";
my $atag="$slang-$tlang";
my $sdiff="$base.diff.$slang";
my $tdiff="$base.diff.$tlang";
system("mkdir -p $atag");

open(DEBUG, ">$base.diff2align.log");	
my $dkref1 = readref("$salign.ref");
my $dkref2 = readref("$stag.ref");
my $enref1 = readref("$talign.ref");
my $enref2 = readref("$ttag.ref");
my $dkhash = diff2align($sdiff, $dkref1, $dkref2);
my $enhash = diff2align($tdiff, $enref1, $enref2);
close(DEBUG);

giza2dtag($diag, $atag, $dkhash, $enhash, "../$slang", "../$tlang", $slang, $tlang);

