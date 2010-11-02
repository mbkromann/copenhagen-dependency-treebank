sub set_type {
	my $self = shift;
	my $name = shift;
	my $type = shift;

	# Delete type from cache, if it has been cached
	my $pos = $self->{'cache_indx'}{$name};
	$self->cache_del($pos) if (defined($pos));

	# Set new type, and return
	return $self->{'types'}{$name} = $type;
}
