sub compute {
	my $self = shift;

	# Find number of data
	my $count = scalar(@{$self->data()});
	my $box = '[' . join(', ', @{$self->box()}) . ']';

	print "$box: count=$count\n";
}

