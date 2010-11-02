sub tunit_governors {
	# Parameters
	my ($self, $tunits, $n) = @_;

	# Find current tunit
	my $tunit = $tunits->{$n};
	my $n0 = $tunit->[0];

	# Find all governor nodes 
	my $governors = {};
	foreach my $g ($self->node_governors(@$tunit)) {
		# Find main node in tunit for $g
		my $g0 = $tunits->{$g}[0];

		# Add $g0 to governors set if $g0 is not in $tunit
		$governors->{$g0} = 1 if ($g0 != $n0);
	}

	# Return
	return sort(keys(%$governors));
}

