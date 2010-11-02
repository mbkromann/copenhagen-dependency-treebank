# phonroots($lexicon, [phons], [tphons1], [tphons2], ...)

sub phonroots {
	my $self = shift;
	my $phons = shift;
	my $roots = { };
	my $hash = $self->{'phonsub'};

	# Add root
	my $base = $self->phon2str(@$phons);
	$roots->{$base} = 1;

	# Process 
	foreach my $tphons (@_) {
		# Find root-changing phons
		my @rphons = ();
		foreach my $p (@$tphons) {
			if ($hash->{$p} || $p =~ '/^s\/.*\/.*\/$/') {
				push @rphons, $p;
			} else {
				last;
			}
		}

		# Add root
		my @myphons = (@$phons, @rphons);
		$self->phon_compile(@myphons);
		my $root = $self->phon2str(@myphons);
		if ($root !~ /^$base.*$/o) {
			$roots->{$self->phon2str(@myphons)} = 1;
		}
	}

	# Return roots
	return uniq(sort(keys(%$roots)));
}
