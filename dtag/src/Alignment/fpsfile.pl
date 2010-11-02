=item $graph->fpsfile($fpsfile) = $fpsfile

Get/set follow postscript file associated with graph.

=cut

sub fpsfile {
	my $self = shift;
	return $self->var('fpsfile', @_);
}
