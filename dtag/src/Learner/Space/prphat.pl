sub prphat {
	my $self = shift;
	$self->{'prphat'} = shift if (@_);
	return $self->{'prphat'};
}
