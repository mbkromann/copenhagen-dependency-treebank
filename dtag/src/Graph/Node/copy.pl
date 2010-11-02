=item Node->copy() = $node

Create new copy of node.

=cut

sub copy {
	# Create new node
	my $self = shift;
	my $copy = Node->new();

	# Copy old node to new node
	foreach my $key (keys(%$self)) {
		if ($key !~ /^\_/) {
			$copy->{$key} = $self->{$key};
		}
	}
	$copy->input($self->input());

	# Return copy
	return $copy
}

