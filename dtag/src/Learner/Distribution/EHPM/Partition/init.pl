sub init {
	my $self = shift;
	my $distribution = shift;
	my $data = shift;
	my $plane = shift || $self->plane();
	my $space = shift || $self->space();

	# Compile parameters and store them
	my $hierarchy = $distribution->hierarchy();
	$self->data($data);
	$self->plane($plane);
	$self->space($space);
	$self->plane_box($hierarchy->space2box($plane));
	$self->space_box($hierarchy->space2box($space));
	$self->{'opt_partitioning'} = undef;

	# Return partition
	return $self;
}
