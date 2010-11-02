# $self->set_hash($var, $inheritance, $key1 => $val1, ...)

sub set_hash {
	my $self = shift;
	my $var = shift;

	# Set inheritance
	my $inherit = shift;
	if ((! ref($_[0])) && ($_[0] eq '=')) {
		$inherit = 0;
		shift;
	}

	# Build plus hash and minus list
	my $hash = {};
	my $minus = [];
	while (@_) {
		my ($key, $value) = (shift, shift);
		if (defined($value)) {
			$hash->{$key} = $value;
		} else {
			push @$minus, $key;
		}
	}

	# Create hash object
	$self->lvar($var, DTAG::LexInput::hash($hash, $minus, $inherit));

	# Return
	return $self;
}


