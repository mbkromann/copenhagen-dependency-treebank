sub compile_count {
	my $self = shift;
	$| = 1;

	# Delete counts for all super types
	foreach my $type (keys(%{$self->{'sub'}})) {
		my $tobj = $self->{'types'}{$type};
		next() if (! defined($tobj));
		delete $tobj->{'count'};
		$self->set_type($type, $tobj);
	}

	# Go through all types
	foreach my $type (keys(%{$self->{'sub'}})) {
		$self->compile_count_type($type);
	}
}

sub compile_count_type {
	my $self = shift;
	my $type = shift;

	# Return 0 if type does not exist
	my $tobj = $self->{'types'}{$type};
	return 0 if (! defined($tobj));

	# Return count if stored for type
	my $count = $tobj->lvar('count');
	return ($count || 0) if (defined($count));

	# Compute count as sum of counts for all subtypes
	$count = 0;
	foreach my $sub (@{$self->subtypes($type)}) {
		$count += $self->compile_count_type($sub);
	}

	# Store count in type
	$tobj->lvar('count', $count);
	$self->set_type($type, $tobj);

	# Return sum
	return $count;
}

