sub edge_setdiff {
	# Find all edges on $list1 which are not on $list2
	my $list1 = shift || [];
	my $list2 = shift || [];
	my $sep = shift;
	my $diff = [];

	# Compare edge lists
	foreach my $e1 (@$list1) {
		my $found = 0;
		foreach my $e2 (@$list2) {
			if ($e1->eq($e2)) {
				$found = 1;
				last;
			}
		}
		if (! $found) {
			push @$diff, $e1;
			printf "%s %s %s %s\n", 
				$sep, $e1->in(), $e1->type(), $e1->out();
		}
	}

	# Return edges in $list1 not found in $list2
	return $diff;
}
