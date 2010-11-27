=item $graph->fpsfile($fpsfile) = $fpsfile

Get/set follow postscript file associated with graph.

=cut

sub fpsfile {
	my $self = shift;
	my $key = shift;
	$key = "" if (! defined($key));
	return $self->var('fpsfile' . $key, @_);
}
