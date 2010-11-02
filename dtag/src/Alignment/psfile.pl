=item $graph->psfile($psfile) = $psfile

Get/set PostScript file associated with graph.

=cut

sub psfile {
	my $self = shift;
	return $self->var('psfile', @_);
}
