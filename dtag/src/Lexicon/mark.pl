sub mark {
	my $self = shift;
	my $type = shift;
	my $name = $type->get_name() || "";

	# Set mark, if argument provided
	if (@_) {
		$self->marks()->{$name} = shift;
	}

	# Return mark
	return $self->marks()->{$name} || -1;
}
