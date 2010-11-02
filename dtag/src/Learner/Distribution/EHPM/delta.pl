sub delta {
	my $self = shift;
	my $cover1 = shift;
	my $cover2 = shift;

	# Return difference in minus-log posterior probability
	return $self->mlog_posterior($cover2) - $self->mlog_posterior($cover1);
}
