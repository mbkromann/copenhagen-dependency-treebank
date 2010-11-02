sub lvar {
	my $self = shift;
	my $var = shift;

	# Set value if specified
	if (@_) {
		my $val = shift;
		if (defined($val)) {
			$self->{$var} = $val;
		} else {
			delete($self->{$var});
		}
	}

	# Retrieve value
	return $self->{$var};
}
