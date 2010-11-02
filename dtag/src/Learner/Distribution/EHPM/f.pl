sub f {
	my $self = shift;
	my $x = shift;
	my $cover = shift || $self->cover();

	# Find partition containing $x
	my $partition = $self->find_partition($x, $cover);

	# Return f-value computed by that partition
	return $partition ? $partition->f($x, $self) : undef;
}
