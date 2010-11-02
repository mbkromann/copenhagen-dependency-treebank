sub get_type {
	my $self = shift;
	my $name = shift;
	my $indx = $self->{'cache_indx'}{$name};
	my $pos = $self->{'cache_pos'} || 0;
	my $type;

	# Check whether type is in cache
	if (defined($indx)) {
		# Type is already stored in cache
		$type = $self->{'cache'}[$indx];
	} else {
		# Fetch type from tied hash
		$type = $self->{'types'}{$name};
	}

	# Update cache if $type is defined
	if (defined($type)) {
		# Delete old type at position $pos
		$self->cache_del($pos);

		# Store new type in cache
		$self->{'cache_indx'}{$name} = $pos;
		$self->{'cache'}[$pos] = $type;
		$pos = ($pos + 1) % ($self->{'cache_size'});
		$self->{'cache_pos'} = $pos;
	}

	# Return type
	return $type;
}
