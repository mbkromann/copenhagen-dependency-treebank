# $self->delta($cover1, $cover2): compute increase in -logp by
# going from $cover1 to $cover2
sub delta {
	my $self = shift;
	my $cover1 = shift;
	my $cover2 = shift;

	# Compute -logp of $cover1
	my $mlogp1 = 
		scalar(@$cover1) 
			? $self->cost($cover1)
			: 0;

	# Compute -logp of $cover2
	my $mlogp2 = 
		scalar(@$cover2) 
			? $self->cost($cover2)
			: 0;

	# Return difference
	return $mlogp2 - $mlogp1;
}
