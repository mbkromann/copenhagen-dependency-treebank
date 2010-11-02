=item $edge->clone() = $clone

Return clone $clone of edge $edge.

=cut

sub clone {
	my $self = shift;
	return Edge->new($self->in(), $self->out(), $self->type());
}
