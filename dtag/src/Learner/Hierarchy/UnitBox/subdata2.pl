sub subdata2 {
	my $self = shift;
	my $subspace = shift;
	my $data = shift;
	my $mindata = shift || 5;

	# Calculate parameters
	my $dim = $self->dimension();
	my $branch = $self->branching();

	# Perform first partition
	my $subdata = $self->subdata($subspace, $data, $mindata);

	# Return all partitions
	return $subdata;
}


