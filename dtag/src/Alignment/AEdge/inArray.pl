sub inArray {
	my $self = shift;
	if (@_) {
		my $array = shift;
		$self->in(($#$array == 0) ? $array->[0] : $array);
	}

	my $in = $self->in();
	return UNIVERSAL::isa($in, "ARRAY") ? $in : [ $in ];
}
