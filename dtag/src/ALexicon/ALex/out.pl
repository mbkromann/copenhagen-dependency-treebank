sub out {
	my $self = shift;
	$self->[0] = shift if (@_);
	return $self->[0] || [];
}
