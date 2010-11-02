sub after {
	my $self = shift;
	my $edge = shift;

	return $edge->before($self);
}

