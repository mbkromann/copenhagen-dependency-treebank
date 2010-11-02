sub nodes_with_valid_attr {
	my $self = shift;
	my $attr = shift;
	my $nodes = [];
	for (my $i = 0; $i < $self->size(); ++$i) {
		my $node = $self->node($i);
		my $val;
		push @$nodes, $i
			if (! $node->comment() && defined($val = $node->var($attr)));
	}
	return $nodes;
}



