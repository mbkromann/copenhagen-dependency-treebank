sub graphid {
	my $self = shift;
	my $graph = shift;

	my $graphs = $self->{'graphs'};
	for (my $i = $#$graphs; $i >= 0; --$i) {
		return $i + 1 if ($graphs->[$i] == $graph);
	}
	return 0;
}

