=item $graph->component($component, $node, $direction) = $component

Compute hash $component containing all nodes in the component
containing $node$. 

=cut

sub component {
	my $self = shift;
	my $node = shift;
	my $component = shift() || {};
	my $direction = shift() || 0;

	# Process all nodes
	if (defined($node) && ! defined($component->{$node})) {
		# Find node object
		my $nodeobj = $self->node($node);
		$component->{$node} = 1;

		# Skip node if it is a comment, a filler, or undefined
		return $component if ((! $nodeobj) || $nodeobj->comment());

		# Compute neighbouring nodes
		my @neighbours = ();
		push @neighbours, map {$_->out()} @{$nodeobj->in()};
		push @neighbours, map {$_->in()} @{$nodeobj->out()};
		
		# Follow links
		foreach my $n (@neighbours) {
			$self->component($n, $component, $direction);
		}
	}

	# Return component
	return $component;
}


