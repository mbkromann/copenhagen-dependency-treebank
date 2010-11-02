=item $text->lexicon_stream($stream, $lexicon) = $lexicon

Get/set lexicon for stream $stream.

=cut

sub lexicon_stream {
	my $self = shift;
	my $stream = shift || 0;

	$self->[$TEXT_LEXICONS]{$stream} = shift if (@_);
	return $self->[$TEXT_LEXICONS]{$stream} || $self->lexicon();
}
