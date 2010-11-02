sub clone {
	my $self = shift;
	
	# Clone this partition
	my $clone = $self->new();
	$clone->count($self->count());
	$clone->data($self->data());
	$clone->plane($self->plane());
	$clone->space($self->space());
	$clone->space_box($self->space_box());
	$clone->plane_box($self->plane_box());

	# Return clone
	return $clone;
}
