sub xml2edge {
	my $etypes = shift;
	my $out = shift;

	# Process feature-value pairs
	my ($in, $label);
	while (@_) {
		my $feature = shift;
		my $value = shift;
		
		# Ignore undefined feature value pairs
		next() if (! defined($feature) || ! defined($value));

		# Save feature-value pair, if defined
		if ($feature eq 'idref') {
			# Incoming node id
			$in = $value;
		} elsif ($feature eq 'label') {
			# Edge label
			$label = $value;
		}
	}

	# Create edge
	return Edge->new($in, $out, $label);
}

