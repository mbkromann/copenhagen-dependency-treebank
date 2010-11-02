sub crossing {
	my $self = shift;
	my $edge = shift;

	# Return undef if edges do not have same out- and in-key
	return undef if ($self->outkey() ne $edge->outkey() 
		|| $self->inkey() ne $edge->inkey());

	# Return 0 if edges do not cross
	return 0 if ($self->before($edge) || $self->after($edge));
	
	# Return 1 if edges cross
	return 1;
}

