sub id2node {
	my $self = shift;
	my $id = shift;
	my $ids = $self->ids();

	# Lookup id
	return $ids->{$id};
}

