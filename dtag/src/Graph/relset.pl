sub relset {
	my $self = shift;
	my $interpreter = $self->interpreter();
	return $interpreter->var("relsets")->{
		$self->relsetname(shift) || ""} || {};
}
