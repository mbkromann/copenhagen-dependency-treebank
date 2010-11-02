sub data {
	my $self = shift;
	if (@_) {
		my $data = $self->{'data'} = shift;
		$self->count($data->count());
	}
	return $self->{'data'};
}
