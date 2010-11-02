	sub tunit_upnodes_visit {
		my ($self, $tunits, $revgraph, $visited, $n) = @_;

		# Mark $n as visited
		$visited->{$n} |= 1;

		# Visit parents of $n and add parent edges to $revgraph
		foreach my $m ($self->tunit_governors($tunits, $n)) {
			# Add dominating edge to reverse graph
			$revgraph->{$m}{$n} = 1;

			# Visit $m if it has not been visited before
			$self->tunit_upnodes_visit($tunits, $revgraph, $visited, $m)
				if (! (($visited->{$m} || 0) & 1));
		}
	}

