sub is_dependent {
	my ($self, $edge) = @_;
	
	# Return 1 if edge is a complement
	return $self->is_complement($edge) || $self->is_adjunct($edge);
}

