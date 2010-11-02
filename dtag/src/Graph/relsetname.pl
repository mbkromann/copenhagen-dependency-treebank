sub relsetname {
	my $self = shift;
	my $interpreter = $self->interpreter();
	return shift || $self->var("relset") 
		|| $interpreter->var("relset");
}
