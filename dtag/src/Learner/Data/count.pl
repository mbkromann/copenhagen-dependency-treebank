# $self->count() = $count: compute number of observations in data set

sub count {
	my $self = shift;

	# Return number of data
	return scalar(@{$self->data()});
}
