sub new_data {
	my $self = shift;
	my $data = shift;
	my $fdata = $self->filter($data);
	$self->data($fdata->[0]);
	$self->rdata($fdata->[0]);
	return $fdata->[1];
}

