=item $self->lexicon($lexicon) = $lexicon

Get/set lexicon associated with graph.

=cut

sub lexicon {
	my $self = shift;
	$self->{'lexicon'} = shift if (@_);
	return $self->{'lexicon'} || DTAG::Interpreter->interpreter()->lexicon();
}
