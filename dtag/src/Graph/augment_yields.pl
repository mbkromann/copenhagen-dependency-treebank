sub augment_yields {
	my $self = shift;
	my $var = shift || "_yield";
	my $yields = $self->yields();
	for (my $i = 0; $i < $self->size(); ++$i) {
		my $node = $self->node($i);
		my $yield = $yields->{$node};
	}
}
