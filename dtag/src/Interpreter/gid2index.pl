sub gid2index {
	my $self = shift;
	my $graphid = shift;

	# Find graph matching graph_id
	for (my $i = 0; $i < scalar(@{$self->{'graphs'}}); ++$i) {
		if ($self->{'graphs'}[$i]->id() eq $graphid) {
			return $i;
		}

		# Abort if requested
		last() if ($self->abort());
	}

	# Not found
	return undef;
}
