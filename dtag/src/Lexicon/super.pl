sub super {
	my $self = shift;
	my $type = typeobj(shift);
	my $name = shift;
	my $mark = @_ ? shift : $self->newmark();
	
	# Return 0 if $type does not exist, or if $type already bears $mark
	return 0 if (! $type);

	# Return 1 if $type has name $name
	if ($type->get_name() eq $name) {
		return 1;
	}

	# Examine super types
	if ($self->mark($type) != $mark) {
		foreach my $s (@{$type->get_super()}) {
			if ($self->super($s, $name, $mark)) {
				return 1;
			}
		}
		$self->mark($type, $mark);
	}

	# Otherwise return 0
	return 0;
}
