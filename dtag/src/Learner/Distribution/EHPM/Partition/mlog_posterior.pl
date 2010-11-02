sub mlog_posterior {
	my $self = shift;
	$self->{'mlog_posterior'} = shift if (@_);
	return $self->{'mlog_posterior'};
}
