sub isarel {
	my $self = shift;
	my $rel = shift;
	my $superrel = shift;
	my $relset = shift;

	# Create matcher object
	my $matcher = $self->interpreter()->edge_filter("isa($superrel)");

	# Perform match
	return $matcher->match($self, $rel);
}

