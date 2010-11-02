# $ehpm->find_partition($x) = $partition: find partition in ordered cover
# containing $x

sub find_partition_index {
	my $self = shift;
	my $x = shift;
	my $cover = shift || $self->cover();

	# Process ordered cover
	my $hierarchy = $self->hierarchy();
	for (my $i = 0; $i <= $#$cover; ++$i) {
		my $partition = $cover->[$i];
		return $i
			if $hierarchy->box_inside($partition->space_box(), $x);
	}

	# No partition contains $x
	return undef;
}
