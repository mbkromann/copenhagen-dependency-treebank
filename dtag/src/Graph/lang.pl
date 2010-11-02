sub lang {
	my $self = shift;
	my $node = shift;
	my $N = $self->node($node);
	return (defined $N ? $N->var('_lang') : "")
		|| $self->var('lang')
		|| "";
}
