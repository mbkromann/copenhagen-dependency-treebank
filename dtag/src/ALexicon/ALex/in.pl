sub in {
	my $self = shift;
	$self->[1] = shift if (@_);
	return $self->[1] || [];
}
