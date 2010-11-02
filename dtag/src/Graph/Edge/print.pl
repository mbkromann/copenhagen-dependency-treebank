=item $edge->print() = $string

Return string representation of edge (used for debugging only).

=cut

sub print {
	my $self = shift;
	return "edge("
		. "in=" . $self->in()
		. " out=" . $self->out()
		. " type=" . $self->type() . ")";
}
