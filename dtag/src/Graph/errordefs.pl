# Return error definitions sorted by increasing priority
sub errordefs {
	my $self = shift;

	# Ensure error definitions exist
	my $errordefs = $self->{'errordefs'};
	$errordefs = $self->{'errordefs'} = $self->interpreter()->errordefs() 
		if (! defined($errordefs));

	# Return error definitions
	return $errordefs;
}
