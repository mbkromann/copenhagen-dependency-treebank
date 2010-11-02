# $type->agov('=', $edge1=>$type1, ...)


sub agov {
	my $self = shift;
	return $self->set_hash('agov', 3, @_);
}


