sub crossings {
	my $self = shift;
	my $edge = shift;
	my $crossings = $self->var('crossings');
	return ($crossings && exists $crossings->{$edge}) ? $crossings->{$edge} : [];
}
