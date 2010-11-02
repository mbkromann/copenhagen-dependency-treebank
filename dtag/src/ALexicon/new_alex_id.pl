sub new_alex_id {
	my $self = shift;
	my $old = $self->var('alex_id') || 0;
	$self->var('alex_id', $old + 1);
	return $old;
}
