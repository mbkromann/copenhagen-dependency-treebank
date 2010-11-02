=item $parse->parseops($parseops) = $parseops

Get/set list of parsing operations.

=cut

sub parseops {
	my $self = shift;
	$self->{'parseops'} = shift if (@_);
	return $self->{'parseops'};
}

