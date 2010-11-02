sub supertypes {
	my $self = shift;
	my $type = shift;
	return $self->{'super'}{$type} || [];
}
