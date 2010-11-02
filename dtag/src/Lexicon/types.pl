sub types {
	my $self = shift;

	# Return list with all types
	return [sort(keys(%{$self->{'types'}}))];
}
