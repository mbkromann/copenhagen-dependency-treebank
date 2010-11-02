sub stackhash {
	my $self = shift;
	$self->{'stackhash'} = shift if (@_);
	return $self->{'stackhash'};
}
