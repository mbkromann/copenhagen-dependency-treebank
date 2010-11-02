sub erase_all {
	my $self = shift;
	my $alexicon = $self->alexicon();
	my $graphs = $self->graphs();

	$self->clear();
	$self->alexicon($alexicon);
	$self->graphs($graphs);
}

