sub var {
	my $self = shift;
	my $var = shift;

	# Set variable, if value given
	$self->{$var} = shift if (@_);

	# Return variable
	return $self->{$var};
}
