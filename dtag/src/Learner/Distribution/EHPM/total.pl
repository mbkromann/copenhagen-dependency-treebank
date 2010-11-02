sub total {
	my $self = shift;
	$self->{'total'} = shift if (@_);
	return $self->{'total'};
}
