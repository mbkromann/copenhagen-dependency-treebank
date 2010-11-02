sub cache_del {
	my $self = shift;
	my $pos = shift;

	# Delete type stored in current position of cache 
	my $oldtype = $self->{'cache'}[$pos];
	if (defined($oldtype)) {
		# Find name of type and corresponding position in cache
		my $oldname = $oldtype->get_name();
		my $oldpos = $self->{'cache_indx'}{$oldname} || -1;

		# Delete old type if $oldpos coincides with $pos (ie, no newer
		# reference exists in the cache)
		if ($oldpos == $pos) {
			delete $self->{'cache_indx'}{$oldname};
		}
	}
}
