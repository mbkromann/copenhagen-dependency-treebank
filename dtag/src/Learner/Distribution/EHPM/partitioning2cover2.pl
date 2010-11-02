sub partitioning2cover2 {
	my $self = shift;
	my $i = shift;
	my $partitioning = shift;

	# Create new cover
	my $newcover = [@{$self->cover()}];
	splice(@$newcover, $i, 1, @$partitioning[1..$#$partitioning]);
	
	# Return new cover
	return $newcover;
}
