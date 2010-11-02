sub tunit_complements {
	# Parameters
	my ($self, $tunits, $n) = @_;

	# Find current tunit
	my $tunit = $tunits->{$n};
	my $n0 = $tunit->[0];

	# Find all nodes that 
	my $dependents = {};
	foreach my $d ($self->node_complements(@$tunit)) {
		# Find main node in tunit for $d
		my $d0 = $tunits->{$d}[0];

		# Add $d0 to dependents set if $d0 is not in $tunit
		$dependents->{$d0} = 1 if ($d0 != $n0);
	}

	# Return
	return sort(keys(%$dependents));
}

