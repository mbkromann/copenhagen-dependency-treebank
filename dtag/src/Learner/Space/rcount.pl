sub rcount {
	my $self = shift;
	return scalar(@{$self->rdata()});
}
