sub xreplace {
	my $self = shift;
	my $changes = shift;
	my $replace = $changes->{$self};

	return $replace->xreplace($changes) || $self;
}
