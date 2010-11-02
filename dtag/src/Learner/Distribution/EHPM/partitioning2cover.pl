sub partitioning2cover {
	my $self = shift;
	my $i = shift;
	my $partitioning = shift;

	# Extract parameters
	my $delta = $partitioning->[0];
	my $child = $partitioning->[1];
	my $parent = $partitioning->[2];

	# Create new cover
	my $newcover = [@{$self->cover()}];
	splice(@$newcover, $i, 1, $child, $parent);
	
	# Return new cover
	return $newcover;
}
