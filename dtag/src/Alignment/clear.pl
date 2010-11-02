sub clear {
	my $self = shift;

	$self->var('graphs', {});
	$self->var('imin', {});
	$self->var('imax', {});
	$self->var('edges', []);
	$self->var('offsets', {});
	$self->var('nodes', {});
	$self->var('crossings', {});
	$self->var('window', 10);

	# Return
	return $self;
}	

