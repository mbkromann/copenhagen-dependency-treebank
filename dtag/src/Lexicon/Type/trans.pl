# $type->trans('=', $name1=>$trans1, ...)


sub trans {
	my $self = shift;
	return $self->set_hash('trans', 3, @_);
}


