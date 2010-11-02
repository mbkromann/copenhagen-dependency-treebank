# $type->phon($var, $inheritance, $phon1, ..., $phonN):
sub set_list {
	my $self = shift;
	my $var = shift;

	# Set inheritance
	my $inherit = 1;
	if ((! ref($_[0])) && ($_[0] eq '=')) {
		$inherit = 0;
		shift;
	}

	# Initialize value
	$self->lvar($var, DTAG::LexInput::list([@_], [], $inherit));

	# Return
	return $self;
}

