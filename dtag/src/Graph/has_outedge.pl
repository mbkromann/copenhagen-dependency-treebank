sub has_outedge {
	my ($self, $node) = @_;

	# False if node is undefined
	return 0 if (! defined($node));

	# Run through edges to find match
	foreach my $edge (@{$node->out()}) {
		foreach my $type (@_) {
			return 1 if ($self->interpreter()->is_relset_etype($edge,
				$type, $self->relset()));
		}
	}

	# Nothing found
	return 0;
}
