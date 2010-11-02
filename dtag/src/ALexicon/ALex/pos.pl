sub pos {
	my $self = shift;
	$self->[3] = shift if (@_);
	return $self->[3] || 0;
}
