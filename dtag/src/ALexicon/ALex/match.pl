sub match {
	my $self = shift;
	my $out = shift;
	my $type = shift;
	my $in = shift;

	# Check type
	return 0 
		if ($self->type() ne $type
			|| (! list_eq($self->in(), $in)) 
			|| (! list_eq($self->out(), $out))
		);
	
	# Return match
	return 1;
}

sub list_eq {
	my $list1 = shift;
	my $list2 = shift;

	return 0 if (scalar(@$list1) ne scalar(@$list2));

	for (my $i = 0; $i < scalar(@$list1); ++$i) {
		return 0 if (
			(defined($list1->[$i]) ? $list1->[$i] : "__UNDEFINED__")
			ne 
			(defined($list2->[$i]) ? $list2->[$i] : "__UNDEFINED__"))
	}

	# All elements matched
	return 1;
}
