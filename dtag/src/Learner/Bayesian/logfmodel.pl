# logfmodel($ndist, $ndata) = $prob: compute probability of model
sub logfmodel {
	my $self = shift;

	# Maximum likelihood estimation: all models are equiprobable
	return log($self->fmodel(@_));
}
