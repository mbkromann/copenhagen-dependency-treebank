# $type->phon($phon1, ..., $phonN):

sub phon {
	my $self = shift;

	# Compile $phon1 ... $phonN
	$self->lexicon()->phon_compile(@_);

	# Set list
	return $self->set_list('phon', @_);
}


