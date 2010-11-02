
sub node {
	my $self = shift;
	my $datum = shift;

	# Die because method isn't implemented
	die "Method node() not implemented in class " . (ref($self) || "?");
}
