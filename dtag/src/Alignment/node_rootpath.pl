# Find root path for node
sub node_rootpath {
	# Parameters
	my ($self, $node) = @_;

	# Calculate governors
	my @governors = $self->node_governors($node);
	print "    governors($node): ", join(" ", @governors), "\n";

	# Process governors
	if (scalar(@governors) == 0) {
		# Root node: return node alone
		return ($node);
	} elsif (scalar(@governors) == 1) {
		# Single governor: return concatenation of governor path and
		# governor
	} else {
		# More than one governor: return first governor path and print
		# error
		print "ERROR: node $node has multiple governors ",
			join(" ", @governors), ": ignoring all other than the first\n";
	}

	# Return
	return ($self->node_rootpath($governors[0]), $node);
}

