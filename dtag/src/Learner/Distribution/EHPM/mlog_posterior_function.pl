sub mlog_posterior_function {
	my $self = shift;
	$self->{'mlog_posterior_function'} = shift() if (@_);
	return $self->{'mlog_posterior_function'} || $mlog_posterior_function;
}
