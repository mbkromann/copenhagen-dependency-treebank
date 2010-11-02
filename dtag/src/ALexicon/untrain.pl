sub untrain {
	my $self = shift;

	# Initialize variables
	$self->alex([]);
	$self->out({});
	$self->in({});
	$self->var('gaps', {});
	$self->var('regexps', {});

	# Set empty sublexicon, if no existing sublexicon array
	$self->sublexicons([]) if (! $self->sublexicons());

	# Return
	return $self;
}	
