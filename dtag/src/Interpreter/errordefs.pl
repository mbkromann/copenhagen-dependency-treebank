# Return error definitions sorted by increasing priority
sub errordefs {
	my $self = shift;

	# Ensure error definitions exist
	my $errordefs = $self->{'errordefs'};
	if (! defined($errordefs)) {
		$self->{'errordefs'} = $errordefs = {
			'@node' => [], '@edge' => [],
			'node' => {}, 'edge' => {}
		};
	}

	# Return error definitions
	return $errordefs;
}
