sub dimension {
	my $self = shift;
	$self->{'dimension'} = shift if (@_);
	return $self->{'dimension'};
}
