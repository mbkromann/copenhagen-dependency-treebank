# Compute the errors for a node in a graph, using the code supplied by
# the error definitions associated with the graph.

sub errors_node {
	my ($self, $n) = @_;

	# Initialize results and node
	my $results = [];
	return $results if (! $n);

	# Retrieve errordefs and sort them according to priority (array index 2)
	my $errordefs = $self->errordefs()->{"node"};
	my $errornames = $self->errordefs()->{'@node'};

	# Retrieve list of noerrors
	my $noerror = $n->var("_noerror") || "";

	# Process nodes
	foreach my $error (@$errornames) {
		# Skip if error is marked as noerror
		next if ($noerror =~ /:$error:/);

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
