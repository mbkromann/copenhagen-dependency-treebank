sub superiors {
	my $self = shift;
	my $superiors = [];

	# Find superiors = older siblings of node, parent, grandparent, etc.
	my $child = $self;
	my $parent = $self->super();
	while($parent) {
		foreach my $sibling (@{$parent->subspaces()}) {
			if ($sibling == $child) {
				last();
			} else {
				push @$superiors, $sibling;
			}
		}
		$child = $parent;
		$parent = $parent->super();
	}

	# Return superiors
	return $superiors;
}

