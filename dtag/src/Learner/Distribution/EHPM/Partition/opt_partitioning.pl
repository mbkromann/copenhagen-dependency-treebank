sub opt_partitioning {
	my $self = shift;
	$self->{'opt_partitioning'} = shift if (@_);
	return $self->{'opt_partitioning'};
}

