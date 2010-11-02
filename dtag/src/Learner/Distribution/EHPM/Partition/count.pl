sub count {
	my $self = shift;
	$self->{'count'} = shift if (@_);
	my $data = $self->data();
	return $data ? $data->count() : $self->{'count'};
}
