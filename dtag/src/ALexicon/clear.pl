sub clear {
	my $self = shift;

	# Initialize variables
	$self->alex([]);
	$self->out({});
	$self->in({});
	$self->fout({});
	$self->fin({});
	$self->lang1('');
	$self->lang2('');
	$self->var('gaps', {});
	$self->var('regexps', {});

	# Set empty sublexicon, if no existing sublexicon array
	$self->sublexicons([]) if (! $self->sublexicons());

	# Return
	return $self;
}	

