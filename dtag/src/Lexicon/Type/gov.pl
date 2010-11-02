# $type->gov('=', $edge1=>$type1, ...)


sub gov {
	my $self = shift;
	return $self->set_hash('agov', 3, @_);
}


