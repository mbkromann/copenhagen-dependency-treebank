sub auto_offset {
	my $self = shift;

	# Delete automatically created alignment edges
	$self->delete_creator(-100, -100);
	
	# Find offsets for all graphs
	foreach my $key (keys(%{$self->graphs()})) {
		# Find first node in graph without edges
		my $offset = $self->node_incomplete($key, $self->offset($key));

		# Set offset
		$self->offset($key, $offset);
		$self->imin($key, $offset - $self->var('window'));
	}
}
