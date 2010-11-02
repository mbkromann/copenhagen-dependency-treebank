sub phat {
	my $self = shift;
	$self->{'phat'} = $self->{'rphat'} = shift if (@_);
	return $self->{'phat'};
}
