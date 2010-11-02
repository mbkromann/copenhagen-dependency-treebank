sub xchildren {
	my $self = shift;
	my $changes = shift;

	# Use replacement for $self in changes, if one exists
	my $replacement = $self->xreplace($changes);
	return $replacement->xchildren($changes)
		if ($replacement);

	# Return children of this node
	my $children = $self->children();
	my $xchildren = [];
	foreach my $child (@$children) {
		push @$xchildren,
			$child->xreplace($changes);
	}

	# Return children
	return $xchildren;
}

