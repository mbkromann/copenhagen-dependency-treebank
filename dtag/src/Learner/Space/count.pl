sub count {
	my $self = shift;
	return scalar(@{$self->data()});
}
