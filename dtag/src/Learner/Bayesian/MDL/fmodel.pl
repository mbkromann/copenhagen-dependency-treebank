# fmodel($ndist, $ndata) = $prob: compute probability of model
sub fmodel {
	my $self = shift;

	# Compute parameter description length
	return exp($self->logfmodel(@_));
}
