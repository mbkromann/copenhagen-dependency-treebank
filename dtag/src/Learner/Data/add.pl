# $self->add($outcome, ...) = $self: add outcomes to list of outcomes

sub add {
	my $self = shift;

	# Add outcomes to outcome list, and add outcome ID to data
	push @{$self->outcomes()}, @_;
	push @{$self->data()}, scalar(@{$self->outcomes()}) - 1;

	# Return self
	return $self;
}

