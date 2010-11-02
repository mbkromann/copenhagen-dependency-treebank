sub graph {
	my $self = shift;
	my $key = shift;
	$key = "" if (! defined($key));
	return $self->{'graphs'}{$key};
}
