sub cmd_new {
	my $self = shift;

	# Create new graph
	push @{$self->{'graphs'}}, DTAG::Graph->new($self);

	# Set graph pointer to new graph
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;

	# Update viewer
	$self->cmd_return($self->graph());

	# Return 
	return 1;
}

