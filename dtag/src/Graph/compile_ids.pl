sub compile_ids {
	my $self = shift;
	my $ids = $self->var("ids", {});

	for (my $i = 0; $i < $self->size(); ++$i) {
		my $N = $self->node($i);
		if (! $N->comment()) {
			my $id = $N->var("id");
			if (defined($ids->{$id})) {
				warning("Nodes " . $ids->{$id} . " and $i have identical ids $id... skipping $i");
			} else {
				$ids->{$id} = $i;
			}
		}
	}
}
