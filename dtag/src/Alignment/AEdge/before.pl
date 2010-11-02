sub before {
	my $self = shift;
	my $edge = shift;

	# Return undef if edges do not have same out- and in-key
	return undef if ($self->outkey() ne $edge->outkey() 
		|| $self->inkey() ne $edge->inkey());

	# Return 0 if $self is entirely before $edge, 1 otherwise
	return (max(@{$self->outArray()}) < min(@{$edge->outArray()})
			&& max(@{$self->inArray()}) < min(@{$edge->inArray()}))
		? 1 : 0;
}

