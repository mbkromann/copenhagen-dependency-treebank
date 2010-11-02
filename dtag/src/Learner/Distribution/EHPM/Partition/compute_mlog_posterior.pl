sub compute_mlog_posterior {
	my $self = shift;
	my $distribution = shift;

	# Compute minus-log posterior of partition
	my $mlog_posterior_function = $distribution->mlog_posterior_function();
	return $self->mlog_posterior(
		&$mlog_posterior_function($distribution, $self));
}
