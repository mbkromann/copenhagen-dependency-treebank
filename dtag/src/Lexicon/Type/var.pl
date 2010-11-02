sub var {
	my $self = shift;
	my $var = shift;

	# Set value of local variable, if specified
	if (@_) {
		$self->lvar($var, shift);
	}

	# Retrieve value of variable
	my ($t, $value) = DTAG::Lexicon->xvar($self, $var);
	return $value;
}
