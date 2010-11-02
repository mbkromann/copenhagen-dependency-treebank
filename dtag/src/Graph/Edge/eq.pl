=item $edge->eq($edge2) = $boolean

Test whether $edge and $edge2 represent the same edge.

=cut

sub eq {
	my $self = shift;
	my $edge = shift;
	my $unlabelled = shift;

	return ($self->out() == $edge->out())
		&& ($self->in() == $edge->in())
		&& ($unlabelled || $self->type() eq $edge->type());
}
