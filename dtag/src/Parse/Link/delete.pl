=item $link->delete($delete) = $delete

Get/set deletion variable of link, which indicates whether the link
should be deleted or added to the graph.

=cut

sub delete {
	my $self = shift;
	$self->[$LINK_DELETE] = shift if (@_);
	return $self->[$LINK_DELETE];
}
