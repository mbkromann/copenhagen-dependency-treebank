# Compute the errors for a node in a graph, using the code supplied by
# the error definitions associated with the graph.

sub errors_node {
	my ($self, $n) = @_;

	# Retrieve errordefs and sort them according to priority (array index 2)
	my $errordefs = $self->errordefs()->{"node"};
	my $errornames = $self->errordefs()->{'@node'};

	# Process nodes
	my $results = [];
	foreach my $error (@$errornames) {
		# Call error definition subroutine
		my $sub = $errordefs->{$error}[1];
        if ($sub) {
			my $result = &$sub($self->interpreter(), $self, $n);
			if ($result) {
				push @$results, [$error, $result];
			}
		}
	}

	# Return errors
	return $results;
}
