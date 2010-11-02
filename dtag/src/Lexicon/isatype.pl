sub isatype {
	my $self = shift;
	my $type = shift;
	my $tspec = shift;

	# Check whether $tspec is atomic or composite
	if (ref($tspec) && $tspec->isa("TypeOp")) {
		# Composite
		return $tspec->value($self, $type);
	} else {
		# Atomic
		return $self->super($type, $tspec);
	}
}
