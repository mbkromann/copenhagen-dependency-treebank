sub alex {
	my $self = shift;
	$self->[7] = shift if (@_);
	return $self->[7];
}
