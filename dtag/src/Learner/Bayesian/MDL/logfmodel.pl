# logfmodel($nfree, $ndata) = $prob: compute probability of model
sub logfmodel {
	my $self = shift;
	my $nfree = shift;
	my $ndata = shift;

	# Compute parameter description length
	#my $lM = ($ndist-1) / 2 * log($ndata || 1) / log(2);

	# Compute Bayesian prior probability
	#return - $lM * log(2);
	#return ($ndist - 1) * log($ndata || 1) / 2;
	return $nfree * log($ndata || 1) / 2;
}
