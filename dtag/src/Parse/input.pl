=item $parse->input($input) = $input

Get/set input associated with text.

=cut

sub input {
	my $self = shift;
	if (@_) {
		my $input = $self->{'input'} = shift;
		$self->now($input->time0());
	}
	return $self->{'input'};
}
