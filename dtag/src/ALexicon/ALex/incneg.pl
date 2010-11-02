sub incneg {
	my $self = shift;
	$self->[4] += shift if (@_);
	return $self->[4] || 0;
}
