sub gaps {
	my $self = shift;
	my $type = shift;
	$type = "" if (! defined($type));

	my $gaps = $self->var('gaps');

	return (exists $gaps->{$type})
		? $gaps->{$type} 
		: ($gaps->{$type} = []);
}
