sub super {
	my $self = shift;
	$self->{'_super'} = [@_];
	return $self;
} 
