sub clone {
	my $self = shift;
	my $clone = AEdge->new();

	# Copy array
	for (my $i = 0; $i <= $#$self; ++$i) {
		$clone->[$i] = $self->[$i];
	}

	# Clone in and out arrays
	my $in = $self->in();
	my $out = $self->out();
	$clone->in(UNIVERSAL::isa($in, 'ARRAY') ? [@$in] : $in);
	$clone->out(UNIVERSAL::isa($out, 'ARRAY') ? [@$out] : $out);

	# Return clone
	return $clone;
}

