sub string {
	my $self = shift;

	return join(" ", map {defined($_) ? $_ : "*"} @{$self->out()})
		. " =" . $self->type() . "=> "
		. join(" ", map {defined($_) ? $_ : "*"} @{$self->in()});
}
