sub id {
	my $self = shift;
	$self->[5] = shift if (@_);
	return $self->[5] || [];
}
