=item $text->inputs($inputs) = $inputs

Get/set input hash associated with text.

=cut

sub inputs {
	my $self = shift;
	if (@_) {
		$self->[$TEXT_INPUTS] = shift;
		$self->[$TEXT_TIME1] = undef;
	}
	return $self->[$TEXT_INPUTS];
}
