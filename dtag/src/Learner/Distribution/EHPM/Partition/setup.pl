sub setup {
	my $self = shift;
	my $distribution = shift;
	my $data = shift;
	my $plane = shift;
	my $parent = shift;

	# Compile parameters and store them
	my $space = defined($parent) ? [@{$parent->space()}, @$plane] : $plane;
	$self->init($distribution, $data, $plane, $space);

	# Return partition
	return $self;
}
