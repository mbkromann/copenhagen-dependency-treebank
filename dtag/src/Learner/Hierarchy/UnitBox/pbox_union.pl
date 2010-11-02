sub pbox_union {
	my $self = shift;
	my $f = shift;
	my $box = shift;
	my @union = @_;

	# Find union of intersections with $box
	my @intsct = $self->box_simplify_union($self->box_intsct($box, @union));

	# Debug
	# print "pbox_union: P(" 
	# 	. join(' U ', map {DTAG::Interpreter::dumper($_)} ($box, @union))
	# 	. ") = P(" . DTAG::Interpreter::dumper($box) 
	# 	. ") + P(" . join(' U ', map {DTAG::Interpreter::dumper($_)} @union) 
	# 	. ") - P(" . join(' U ', map {DTAG::Interpreter::dumper($_)} @intsct) 
	# 	. ")\n";

	# Return integral
	return $self->integrate($f, $box)
		+ (@union ? $self->pbox_union($f, @union) : 0)
		- (@intsct ? $self->pbox_union($f, @intsct) : 0);
}
