sub update {
	my $self = shift;

	# Activate autoaligner, if necessary
	my $alexicon = $self->alexicon();
	if ($alexicon && $self->var('autoalign')) {
		$alexicon->autoalign($self);
	}
}
