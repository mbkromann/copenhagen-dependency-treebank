sub contains {
	my $self = shift;
	my $key = shift;
	my $node = shift;

	# Check whether edge contains node
	if ($self->outkey() eq $key) {
		return 1 if (grep {$_ eq $node} @{$self->outArray()});
	} elsif ($self->inkey() eq $key) {
		return 1 if (grep {$_ eq $node} @{$self->inArray()});
	}
	
	# No match
	return 0;
}
