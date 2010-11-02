=item $parse->open_lexemes($open) = $open

Get/set list of open lexemes.

=cut

sub open_lexemes {
	my $self = shift;
	$self->{'open_lexemes'} = shift if (@_);
	return $self->{'open_lexemes'};
}
