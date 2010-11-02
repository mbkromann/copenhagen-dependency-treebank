sub vars {
	my $self = shift;
	return [ grep !/^_/, sort(keys(%$self)) ];
}
