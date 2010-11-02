=item $graph->boundaries($boundaries) = $boundaries

Get/set list of boundaries. ???

=cut

sub boundaries {
	my $self = shift;
	return $self->var('boundaries', @_);
}
