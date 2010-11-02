sub inside { 
	my $self = shift;
	my $list = shift;
	my $from = shift;
	my $to = shift;

	# Return 1 if any node in list is inside the interval
	foreach my $node (@$list) {
		return 1 if ($from <= $node && $node <= $to);
	}

	# Return 0 otherwise
	return 0;
}

sub inside_in {
	my $self = shift;
	return $self->inside($self->inArray(), @_);
} 

sub inside_out {
	my $self = shift;
	return $self->inside($self->outArray(), @_);
} 

