sub signal_handler {
	my $self = shift;
	my $signame = shift;

	# Set abort flag
	$self->abort(1);
}
