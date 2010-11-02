=item $self->lexicon_stream($stream, $lexicon) = $lexicon

Get/set lexicon associated with stream $stream in graph, using
$graph->lexicon() as the default.

=cut

sub lexicon_stream {
	my $self = shift;
	my $stream = shift || 0;

	$self->{'lexstream'}{$stream} = shift if (@_);
	return $self->{'lexstream'}{$stream} || $self->lexicon();
}
