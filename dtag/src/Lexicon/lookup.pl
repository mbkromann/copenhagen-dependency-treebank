sub lookup {
	my $self = shift;
	my $input = shift;
	my @lex = ();

	# Find roots matching $input
	my @roots = ();
	my $rhash = $self->{'roots'};
	my $list;
	for (my $i = 1; $i <= $maxrootlength; ++$i) {
		my $substr = substr($input, 0, $i);
		$list = $rhash->{$substr};
		push @roots, @$list if $list;
	}
	@roots = uniq(@roots);

	# Find transformations matching $input
	$list = [];
	foreach my $root (@roots) {
		$self->lookup_type($input, $root, $list);
	}

	# Return ($lex1, $lex2, ...)
	return $list;
}


