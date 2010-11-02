sub has_inedge {
	my ($self, $node) = (shift, shift);

	# False if node is undefined
	return 0 if (! defined($node));

	# Run through edges to find match
	foreach my $edge (@{$node->in()}) {
		foreach my $type (@_) {
			return 1 if ($self->interpreter()->is_relset_etype($edge->type(),
				$type, $self->relset()));
		}
	}

	# Nothing found
	return 0;
}
