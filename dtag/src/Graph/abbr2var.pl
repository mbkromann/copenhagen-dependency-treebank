=item $graph->abbr2var($abbr) = $var

Find variable name $var corresponding to variable name abbreviation
$abbr.

=cut


sub abbr2var {
	my $self = shift;
	my $abbr = shift;

	# Variable names are returned unchanged
	return $abbr if (exists $self->vars()->{$abbr});

	# Find abbreviation
	foreach my $key (keys %{$self->vars()}) {
		my $value = $self->vars()->{$key};
		return $key if (($value || "") eq $abbr);
	}

	# Return 'estyles' unchanged
	return 'estyles' if ($abbr eq 'estyles');
	if ($self->{'vars.sloppy'}) {
		$self->vars()->{$abbr} = $abbr;
		return $abbr;
	}

	# Not found
	return undef;
}
