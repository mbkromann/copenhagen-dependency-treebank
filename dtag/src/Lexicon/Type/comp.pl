# $self = $self->comp('=', $edge1=>$type1, ...)

sub comp {
	my $self = shift;
	return $self->set_hash('comp', 3, @_);
}


