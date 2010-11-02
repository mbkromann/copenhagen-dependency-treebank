sub branching {
	my $self = shift;
	$self->{'branching'} = shift if (@_);
	return $self->{'branching'};
}
