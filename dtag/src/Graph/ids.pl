sub ids {
	my $self = shift;
	my $ids = $self->var("ids");
	$ids = $self->var("ids", {})
		if (! defined($ids));
	return $ids;
}
