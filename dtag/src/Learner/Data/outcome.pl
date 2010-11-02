sub outcome {
	my $self = shift;
	my $datum = shift;
	return $self->outcomes()->[$datum];
}
