sub pbox_diff {
	my $self = shift;
	my $f = shift;
	my $box = shift;

	# Find union of intersections with $box
	my @union = $self->box_simplify_union($self->box_intsct($box, @_));

	# Return integral
	return $self->integrate($f, $box) 
		- (@union ?  $self->pbox_union($f, @union) : 0);
}
