# $type->fill('=', $edge1=>$type1, ...)


sub fill {
	my $self = shift;
	return $self->set_hash('fill', 3, @_);
}


