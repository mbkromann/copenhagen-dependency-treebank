sub del_node {
	my $self = shift;
	my $ref = shift;

	# Find node and key
	if ($ref =~ /^([a-z])(-?[0-9]+)$/) {
		my $key = $1;
		my $node = $self->rel2abs($key, $2);

		# Process all edges
		my $edges = $self->{'edges'};
		for (my $i = 0; $i < scalar(@$edges); ++$i) {
			my $edge = $edges->[$i];
			
			# Find nodes to match
			my $nodes = [];
			if ($edge->inkey() eq $key) {
				$nodes = $edge->inArray();
			} elsif ($edge->outkey() eq $key) {
				$nodes = $edge->outArray();
			}

			# Delete edge if there is a matching node
			if (grep {$_ eq $node} @$nodes) {
				$self->del_edge($i);
				--$i;
			}
		}
	}
}
