sub is_landing {
	my ($self, $edge) = @_;
	
	# Return 1 if edge is a landing edge
	my $type = ref($edge) ? $edge->type() : $edge;
	return 1 if (grep {$type eq $_} @{$self->etypes()->{'land'} || []});

	# Otherwise return 0
	return 0;
}

