sub var {
	my $self = shift;
	my $var = shift;
	$self->{$var} = shift if (@_);
	return $self->{$var};
}

