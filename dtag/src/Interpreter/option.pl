sub option {
	my $self = shift;
	my $var = shift;
	my $value = shift;
	my $options = $self->{'options'};

	# Set value
	if (defined($value) && defined($var)) {
		$options->{$var} = $value;
	}

	# Return value
	return $options->{$var};
}
