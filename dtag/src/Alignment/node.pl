sub node {
	my $self = shift;
	my $key = shift || "";
	my $node = shift;
	$node = "" if (! defined($node));

	return $self->var('nodes')->{"$key$node"} || [];
}
