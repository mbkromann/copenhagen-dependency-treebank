=item $graph->depths($depths, $node) = $depths

Compute depths hash $depths containing the depth of node $node and the
depth of all other nodes deeply dominating $node.

=cut

sub depths {
	my $self = shift;
	my $depths = shift || {};
	my $node = shift;
	
	# Find node object
	my $nodeobj = $self->node($node);

	# Skip node if it is a comment, a filler, or undefined, or if
	# its depth is defined already
	return $depths if ((! $nodeobj) 
		|| $nodeobj->comment() 
		|| defined($depths->{$node}));
	$depths->{$node} = [];

	# Find deep parent(s) of node
	my $maxdepth = 0;
	foreach my $e (@{$nodeobj->in()}) {
		if ($self->is_dependent($e)) {
			$self->depths($depths, $e->out());
			$maxdepth = max($maxdepth, $depths->{$e->out()} || 0);
		}
	}

	# Calculate depth
	$depths->{$node} = $maxdepth + 1;
		
	# Return depths
	return $depths;
}


