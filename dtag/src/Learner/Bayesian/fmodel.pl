# fmodel($distribution, $ndata) = $prob: compute probability of model
sub fmodel {
	my $self = shift;
	my $dist = shift;
	my $ndata = shift;

	# Maximum likelihood estimation: all models are equiprobable
	return 1;
}
