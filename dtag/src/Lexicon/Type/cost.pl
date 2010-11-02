# $type->cost('=', $name1=>$costf1, ...)


sub cost {
	my $self = shift;
	return $self->set_hash('cost', 3, @_);
}


