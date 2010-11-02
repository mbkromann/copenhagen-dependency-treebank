sub signature {
	my $self = shift;
	return $self->outkey() . scalar(@{$self->outArray})
		. $self->inkey() . scalar(@{$self->inArray}); 
}
