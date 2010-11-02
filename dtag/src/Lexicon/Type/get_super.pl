# get_super := list of super types

sub get_super {
	my $self = shift;
	return $self->{'_super'};
}
