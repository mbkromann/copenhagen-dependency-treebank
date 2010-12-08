# Compute the errors for an edge in a graph, using the code supplied
# by the edge error definitions associated with the graph.

sub errors_edge {
	my ($self, $e) = @_;

	# Retrieve errordefs and sort them according to priority (array index 2)
	my $errordefs = $self->errordefs()->{"edge"};
	my $errornames = $self->errordefs()->{'@edge'};
	my $node = $self->node($e->in());
	my $noerror = $node ? $node->var("_noerror") || "" : "";

	# Process nodes
	my $results = [];
	foreach my $error (@$errornames) {
		# Skip errors listed in $noerror
		next if ($noerror =~ /:$error:/);

		# Call error definition subroutine
		my $sub = $errordefs->{$error}[1];
        if ($sub) {
			my $result = &$sub($self->interpreter(), $self, $e);
			if ($result) {
				push @$results, [$error, $result];
			}
		}
	}

	# Return errors
	return $results;
}
