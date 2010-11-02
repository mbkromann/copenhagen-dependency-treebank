# $ehpm->find_partition($x) = $partition: find partition in ordered cover
# containing $x

sub find_partition {
	my $self = shift;
	my $x = shift;
	my $cover = shift || $self->cover();

	# Process ordered cover
	my $hierarchy = $self->hierarchy();
	foreach my $partition (@$cover) {
		return $partition 
			if $hierarchy->box_inside($partition->space_box(), $x);
	}

	# No partition contains $x
	return undef;
}
