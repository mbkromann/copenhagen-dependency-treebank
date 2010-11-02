sub phon_compile {
	my $self = shift;
	my $hash = $self->phonhash();
	my $phonsub = $self->{'phonsub'};

	while (@_) {
		my $phon = shift;
		my $key = $phon;
		foreach my $op (@{$self->phonops()}) {
			eval('$phon =~ ' . $op);
		}
		if ($phon ne $key) {
			$hash->{$key} = $phon;
		}
	}
	return $self;
}
