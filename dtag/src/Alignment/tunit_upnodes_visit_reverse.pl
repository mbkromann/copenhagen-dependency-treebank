	sub tunit_upnodes_visit_reverse {
		my ($self, $tunits, $revgraph, $visited, $n) = @_;

		# Mark $n as visited
		$visited->{$n} |= 2;

		# Visit parents of $n in reverse graph
		foreach my $m (keys(%{$revgraph->{$n}})) {
			# Visit $m if it has not been visited before
			$self->tunit_upnodes_visit_reverse($tunits, $revgraph, $visited, $m)
				if (! (($visited->{$m} || 0) & 2));
		}
	}

