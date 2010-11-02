sub bindgraph {
	my $self = shift;
	my $bindings = shift;
	my $key = shift || "G";
	$bindings->{$key} = "G:" . $self->id();
}
