sub load_alex {
	my $self = shift;
	my $file = shift;

	# Open file
	open("ALEX", "< $file")
		|| return DTAG::Interpreter::error("cannot open alex-file for reading: $file");

	# Process lexicon file
	my $count = 0;
	while (my $line = <ALEX>) {
		if ($line =~ /^<DTAGalex lang1="([^"]*)" lang2="([^"]*)">$/) {
			# Specify language
			$self->lang1($1);
			$self->lang2($2);
		} elsif ($line =~ /^<sublex file="([^"]*)"\/>$/) {
			# Load sublexicon
			my $sublexicon = ALexicon->new()->load_alex($1);
			push @{$self->sublexicons()}, $sublexicon;
		} elsif ($line =~ /^<alex pos="([^"]*)" neg="([^"]*)" out="([^"]*)" type="([^"]*)" in="([^"]*)"\/>$/) {
			# Create new ALex entry
			$self->add_alex(str2pattern($3), $4, str2pattern($5), $1, $2);
		} elsif ($line =~ /^<gap pos="([0-9]*)" type="([^"]*)" width="([0-9]*)"\/>/) {
			# Record number of gaps
			my $gaps = $self->gaps($2);
			$gaps->[$3] = ($gaps->[$3] || 0) + $1;
			$self->var('total_gaps', 
				($self->var('total_gaps') || 0) + $1);
		} elsif ($line =~ /^<\/DTAGalex>$/ || $line =~ /^<!--.*-->$/) {
			# Do nothing
		} else {
			# Unknown line in .alex file!
			print "ALexicon->load_alex: unknown lexicon line $line in file $file\n";;
		}

		# Print dot for every 1000th line
		++$count;
		$| = 1;
		print "." if ($count % 1000 == 0);
	}
	print "loaded\n";

	# Close file
	close("ALEX");

	# Return alexicon
	return $self;
}

sub str2pattern {
	my $string = shift;
	my $pattern = [ split(/ /, $string) ];
	for (my $i = 0; $i < $#$pattern; ++$i) {
		$pattern->[$i] = undef
			if ($pattern->[$i] eq "*");
	}
	return $pattern;
}
