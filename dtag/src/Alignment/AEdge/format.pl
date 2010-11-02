sub format {
	my $self = shift;
	$self->[8] = shift if (@_);
	return $self->[8];
}
