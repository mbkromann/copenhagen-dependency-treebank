sub cache_clear {
	my $self = shift;

	$self->{'cache'} = [];
	$self->{'cache_indx'} = {};
	$self->{'cache_pos'} = 0;
}
