sub graph {
	my $self = shift;
	my $key = shift;
	$key = "" if (! defined($key));
	return ($key eq "") ? $self : undef;
}
