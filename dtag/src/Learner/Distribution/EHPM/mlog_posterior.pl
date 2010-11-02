sub mlog_posterior {
	my $self = shift;
	my $cover = shift || $self->cover();

	# Compute minus-log probability for each partition in cover
	my $mlog_posterior = 0;
	my $mlog_posterior_function = $self->mlog_posterior_function();
	foreach my $partition (@$cover) {
		# Update minus-log probability in partition 
		$partition->mlog_posterior(
			&$mlog_posterior_function($self, $partition)) 
			if (! defined($partition->mlog_posterior()));

		# Add partition mlog posterior to total mlog posterior
		$mlog_posterior += $partition->mlog_posterior();
	}

	# Return total minus-log posterior probability
	return $mlog_posterior;
}
