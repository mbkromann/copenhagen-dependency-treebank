# $type->land('=', $edge1=>$type1, ...)


sub land {
	my $self = shift;
	return $self->set_hash('land', 3, @_);
}


